require "bundler/setup"
require "active_record"
require "logger"

ActiveRecord::Base.establish_connection(
  adapter: "mysql2",
  host: ENV.fetch("DATABASE_HOST", "db"),
  username: "root",
  password: "password",
  database: "handson",
  encoding: "utf8mb4"
)

class User < ActiveRecord::Base
  has_many :boards
  has_many :comments
end

class Board < ActiveRecord::Base
  belongs_to :user
  has_many :comments
end

class Comment < ActiveRecord::Base
  enum :condition, { published: 0, hide: 1 }
  belongs_to :user
  belongs_to :board
end
