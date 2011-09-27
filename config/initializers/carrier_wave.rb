CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',       # required
    :aws_access_key_id      => ENV['S3_KEY'],       # required
    :aws_secret_access_key  => ENV['S3_SECRET'],       # required
    #:region                 => 'us-east-1b'  # optional, defaults to 'us-east-1'
  }
  #config.fog_host       = 'https://assets.example.com'            # optional, defaults to nil
  #config.fog_public     = false                                   # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
  config.ensure_multipart_form = false
end

if Rails.env.development?
  CarrierWave.configure do |config|
    config.storage = :file
    #config.fog_directory  = 'limelight-dev'
    #config.fog_host = 'http://duenu7rsiu1ze.cloudfront.net'
  end
end

if Rails.env.staging?
  CarrierWave.configure do |config|
    config.storage = :fog
    config.fog_directory  = 'whoot-staging'
    config.fog_host = 'http://d27r8n3epgiojg.cloudfront.net'
  end
end

if Rails.env.production?
  CarrierWave.configure do |config|
    config.storage = :fog
    config.fog_directory  = 'whoot-production'
    config.fog_host = 'http://d27r8n3epgiojg.cloudfront.net'
  end
end