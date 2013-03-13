source 'http://rubygems.org'

ruby '1.9.3'

gem 'rails', '~> 3.2.13.rc2'

gem 'jquery-rails', '2.0.2'
gem 'rack'
gem 'rack-contrib'
gem 'bson_ext'
gem 'mongoid', '~> 2.4' # MongoDB
gem 'mongoid_slug' # Automatic MongoDB slugs
gem 'mongoid_auto_inc' # Auto incrementing fields in mongoid
gem 'devise' # Authentication
gem 'koala', '1.5' # facebook graph api support
gem 'twitter' # twitter api support
gem "omniauth"
gem "omniauth-facebook"
gem 'omniauth-twitter'
gem 'yajl-ruby' # json processing
gem 'resque'
gem 'resque-scheduler', '2.0.0.h' # scheduled resque jobs
gem 'resque-loner' # Unique resque jobs
gem 'resque_mailer'
gem "geocoder"
gem "chronic" # Date/Time management
gem 'cancan' # authorization
gem 'soulmate', '1.0.0'
gem 'dalli' # memcache
gem 'pusher' # pusher publish/subscribe system

gem 'mixpanel', '~> 1.1'
gem 'urbanairship' # push notifications
gem 'backbone-on-rails', '0.9.2.1'
gem "moonshado-sms", :git => 'git://github.com/moonshado/moonshado-sms.git'

gem 'capistrano'
gem 'rvm-capistrano'
gem 'foreman'

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', "~> 3.2.1"
  gem 'compass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  #gem 'therubyrhino'

  gem 'uglifier'

  gem 'anjlab-bootstrap-rails', '~> 2.0.4.3', :require => 'bootstrap-rails'
end

group :production, :staging do
  gem 'thin'
end

group :development do
  gem "pry"
end

gem 'rmagick', :require => false # Image manipulation (put rmagick at the bottom because it's a little bitch about everything)