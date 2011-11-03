Airbrake.configure do |config|
  if Rails.env.staging?
    config.api_key = '1236b076f831c4df73ba75709c1a875b'
  else
    config.api_key = '0a45e0ba6d250adc44e3b92d4e32e47e'
  end
end