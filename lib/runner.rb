require_relative "handson"
require "benchmark"

ROOT = File.expand_path("..", __dir__)
MAX_RUNS = 5
TIME_BUDGET = 2.0
SLOW_THRESHOLD = 5.0

Candidate = Struct.new(:label, :path)
Result = Struct.new(:label, :time, :worst, :queries, :sqls, :status, :error, :notes, keyword_init: true)

def display_width(str)
  str.each_char.sum { |c| c.ord > 0x2E80 ? 2 : 1 }
end

def pad(str, width, align: :left)
  space = " " * [width - display_width(str), 0].max
  align == :left ? str + space : space + str
end

def load_solver(path)
  mod = Module.new
  mod.module_eval(File.read(path), path)
  raise NoMethodError, "solve メソッドが定義されていません" unless mod.method_defined?(:solve)

  Object.new.extend(mod)
end

def capture_sql
  sqls = []
  sub = ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
    sqls << payload[:sql] unless payload[:name] == "SCHEMA" || payload[:cached]
  end
  value = yield
  [value, sqls]
ensure
  ActiveSupport::Notifications.unsubscribe(sub)
end

def judge(check, value)
  verdict = check.call(value)
  verdict == true ? nil : (verdict || "結果が正しくありません")
end

def run_candidate(candidate, exercise)
  solver = load_solver(candidate.path)
  main, *edge_cases = exercise.fetch(:cases)

  value = sqls = nil
  GC.start
  times = [Benchmark.realtime { value, sqls = capture_sql { solver.solve(*main[:args]) } }]
  while times.size < MAX_RUNS && times.sum < TIME_BUDGET
    GC.start
    times << Benchmark.realtime { solver.solve(*main[:args]) }
  end

  problems = []
  notes = []
  if (reason = judge(main[:check], value))
    problems << "#{main[:label]}: #{reason}"
  end
  edge_cases.each do |c|
    if c[:repeat] && times.max > SLOW_THRESHOLD
      notes << "#{c[:label]}のチェックは、1回の実行に#{SLOW_THRESHOLD.to_i}秒以上かかったので省略しました"
      next
    end

    output = c[:repeat] ? Array.new(c[:repeat]) { solver.solve(*c[:args]) } : solver.solve(*c[:args])
    reason = judge(c[:check], output)
    problems << "#{c[:label]}: #{reason}" if reason
  rescue StandardError => e
    problems << "#{c[:label]}: #{e.class}"
  end

  Result.new(label: candidate.label, time: times.sort[(times.size - 1) / 2], worst: times.max, queries: sqls.size, sqls: sqls,
             status: problems.empty? ? "OK" : "NG", error: problems.join(" / ").then { |s| s.empty? ? nil : s },
             notes: notes)
rescue StandardError, ScriptError => e
  Result.new(label: candidate.label, status: "ERROR", error: "#{e.class}: #{e.message.lines.first&.strip}")
end

def format_time(sec)
  return "-" unless sec

  if sec >= 1 then format("%.2f s", sec)
  elsif sec >= 0.001 then format("%.1f ms", sec * 1000)
  else format("%.1f µs", sec * 1_000_000)
  end
end

def format_ratio(baseline, time)
  return "-" unless baseline && time

  ratio = baseline / time
  ratio >= 100 ? "x#{ratio.round.to_s.reverse.scan(/\d{1,3}/).join(',').reverse}" : format("x%.1f", ratio)
end

def progress(message)
  print "\r#{message.ljust(60)}" if $stdout.tty?
end

args = ARGV.reject { |a| a.start_with?("--") }
show_sql = ARGV.include?("--sql")
key = args.first or abort "使い方: bin/run <お題の番号> [--sql]   例: bin/run 02"

dir = Dir[File.join(ROOT, "exercises", "#{key}*")].sort.find { |d| File.directory?(d) }
abort "お題 #{key} が見つかりません（exercises/ の中を確認してください）" unless dir
name = File.basename(dir)
exercise = eval(File.read(File.join(dir, "exercise.rb")), TOPLEVEL_BINDING, File.join(dir, "exercise.rb"))

candidates = [Candidate.new("baseline", File.join(dir, "baseline.rb"))]
candidates += Dir[File.join(ROOT, "my_code", name, "*.rb")].sort.map { |p| Candidate.new("my #{File.basename(p)}", p) }
candidates += Dir[File.join(ROOT, "answers", name, "*.rb")].sort.map { |p| Candidate.new("answer #{File.basename(p, '.rb')}", p) }

puts
puts "お題#{name[/\A\d+/]}: #{exercise.fetch(:title)}"
puts "（comments テーブル: #{Comment.count} 件）" if exercise[:uses_db]
puts

Comment.where(board_id: 2).limit(1).to_a if exercise[:uses_db]

results = candidates.map do |c|
  progress("計測中: #{c.label} ...")
  run_candidate(c, exercise)
end
progress("")
print "\r" if $stdout.tty?

baseline_time = results.first.time
label_width = [results.map { |r| display_width(r.label) }.max, 8].max
header = [pad("名前", label_width), pad("実行時間", 10, align: :right), pad("最遅", 10, align: :right),
          pad("SQL回数", 8, align: :right), pad("baseline比", 11, align: :right), "  結果"].join("  ")
puts header
puts "-" * display_width(header)
results.each do |r|
  puts [pad(r.label, label_width), pad(format_time(r.time), 10, align: :right), pad(format_time(r.worst), 10, align: :right),
        pad(r.queries ? r.queries.to_s : "-", 8, align: :right), pad(format_ratio(baseline_time, r.time), 11, align: :right),
        "  #{r.status}"].join("  ")
end

messages = results.flat_map { |r| [r.error, *r.notes].compact.map { |m| "  #{r.label}: #{m}" } }
unless messages.empty?
  puts
  puts messages
end

if show_sql
  results.each do |r|
    next unless r.sqls

    puts
    puts "[#{r.label}] 発行されたSQL（#{r.sqls.size}回）"
    r.sqls.first(10).each { |sql| puts "  #{sql}" }
    puts "  ...ほか#{r.sqls.size - 10}回" if r.sqls.size > 10
  end
end

puts
puts "実行時間は最大#{MAX_RUNS}回実行した中央値、最遅は一番遅かった回です。"
puts "x の数字は baseline の何倍速いか（x2.0 なら2倍速い）。--sql をつけると発行されたSQLも表示します。"
