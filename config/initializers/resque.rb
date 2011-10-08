require 'resque_scheduler'

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

if Rails.env.production? || Rails.env.staging?
  uri = URI.parse(ENV["REDISTOGO_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  Resque.redis = 'localhost:6379'
end

Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }