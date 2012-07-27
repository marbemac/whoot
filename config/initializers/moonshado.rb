Moonshado::Sms.configure do |config|
  config.api_key = config.api_key = ENV['MOONSHADOSMS_URL'] || 'http://823e917f0735f9c5@heroku.moonshado.com'
  config.production_environment = true
end