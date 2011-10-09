require 'resque_scheduler'

if (Rails.env.production? || Rails.env.staging?) && ENV["REDISTOGO_URL"]
  uri = URI.parse(ENV["REDISTOGO_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
elsif Rails.env.development?
  Resque.redis = 'localhost:6379'
end

Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }