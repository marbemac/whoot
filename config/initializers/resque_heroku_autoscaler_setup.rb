require 'resque/plugins/resque_heroku_autoscaler'

Resque::Plugins::HerokuAutoscaler.config do |c|
  c.heroku_user = ENV['HEROKU_USER']
  c.heroku_pass = ENV['HEROKU_PASSWORD']
  c.heroku_app  = "whoot-#{Rails.env}"

  c.new_worker_count do |pending|
    (pending/5).ceil.to_i # 1 additional worker for every 5 pending jobs
  end
end