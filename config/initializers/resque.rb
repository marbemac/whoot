require 'resque_scheduler'

if Rails.env.production? || Rails.env.staging?
  uri = URI.parse(ENV["REDISTOGO_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }