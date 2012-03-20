Airbrake.configure do |config|
  if Rails.env.staging?
    config.api_key = '1236b076f831c4df73ba75709c1a875b'
  else
    config.api_key = 'ff9be33c7b8b0167ef0a7a37458daae1'
  end
end