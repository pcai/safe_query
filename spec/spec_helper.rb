require "bundler"
Bundler.setup(:default, :development)

require "active_support/all"
require "active_record"
require "safe_query"

ActiveRecord::Base.establish_connection YAML::load(File.open('spec/database.yml'))
ActiveRecord::Base.connection.execute "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, email TEXT, created_at DATETIME, updated_at DATETIME)"

require "models/user"
