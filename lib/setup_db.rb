require_relative "handson"
require "benchmark"

SCALES = { "1m" => 1_000_000, "10m" => 10_000_000 }.freeze
total = SCALES.fetch(ENV.fetch("SCALE", "1m")) do |key|
  abort "SCALE は #{SCALES.keys.join(' / ')} のどれかを指定してください（指定された値: #{key}）"
end

USERS = 300
BOARDS = 100
CHUNK = 1_000_000

conn = ActiveRecord::Base.connection
conn.execute("SET SESSION cte_max_recursion_depth = #{CHUNK}")

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name, null: false
    t.timestamps
  end

  create_table :boards, force: true do |t|
    t.string :title, null: false
    t.text :body, null: false
    t.references :user
    t.integer :condition, default: 0, null: false
    t.timestamps
  end

  create_table :comments, force: true do |t|
    t.references :user
    t.references :board
    t.text :body
    t.timestamps
    t.integer :condition, default: 0, null: false
    t.boolean :is_read, default: false, null: false
  end
end

def sequence(from, to)
  "(WITH RECURSIVE s(n) AS (SELECT #{from} UNION ALL SELECT n + 1 FROM s WHERE n < #{to}) SELECT n FROM s) seq"
end

conn.execute(<<~SQL)
  INSERT INTO users (name, created_at, updated_at)
  SELECT CONCAT('ユーザー', n), NOW(), NOW() FROM #{sequence(1, USERS)}
SQL
conn.execute(<<~SQL)
  INSERT INTO boards (title, body, user_id, created_at, updated_at)
  SELECT CONCAT('掲示板', n), CONCAT('掲示板', n, 'の本文です'), 1 + n % #{USERS}, NOW(), NOW() FROM #{sequence(1, BOARDS)}
SQL

# 掲示板1はコメント0件、掲示板2に全体の1/10、残りを掲示板3〜100に分散させる
elapsed = Benchmark.realtime do
  (1..total).step(CHUNK) do |from|
    to = [from + CHUNK - 1, total].min
    conn.execute(<<~SQL)
      INSERT INTO comments (user_id, board_id, body, created_at, updated_at, `condition`, is_read)
      SELECT 1 + CRC32(n) % #{USERS},
             IF(n % 10 = 0, 2, 3 + n % #{BOARDS - 2}),
             CONCAT('コメント', n, '：いい投稿ですね！参考になりました。'),
             NOW(), NOW(),
             IF(n % 20 = 0, 1, 0),
             n % 3 = 0
      FROM #{sequence(from, to)}
    SQL
    print "\r  comments: #{to.to_s.rjust(total.to_s.size)} / #{total} 件"
  end
  puts
  conn.execute("ANALYZE TABLE comments")
end

puts "  #{total} 件のコメントを #{elapsed.round(1)} 秒で作成しました（掲示板2のコメント: #{Comment.where(board_id: 2).count} 件）"
