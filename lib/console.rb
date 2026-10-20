require_relative "handson"
require "irb"

ActiveRecord::Base.logger = Logger.new($stdout)
puts "User / Board / Comment が使えます。発行されたSQLと実行時間がログに出ます。（終了は exit）"
IRB.start
