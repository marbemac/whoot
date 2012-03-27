require 'rbconfig'
source 'http://rubygems.org'

gem 'rails', '3.2.3.rc1'
gem 'execjs'
gem 'jquery-rails'
gem 'mongoid' # MongoDB
gem 'mongoid_slug' # Automatic MongoDB slugs
gem 'mongoid_auto_inc' # Auto incrementing fields in mongoid
gem 'devise' # Authentication
gem 'koala' # facebook graph api support
gem 'twitter' # twitter api support
gem "omniauth"
gem "omniauth-facebook"
gem 'omniauth-twitter'
gem 'fog' # Cloud support (amazon s3, etc)
gem 'carrierwave' # File uploads
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
# gem 'resque', :git => 'https://github.com/hone/resque.git', :branch => 'heroku'
# gem 'resque-scheduler', '2.0.0.g' # scheduled resque jobs
# gem 'resque-loner' # Unique resque jobs
gem "geocoder"
gem "chronic" # Date/Time management
gem 'cancan' # authorization
gem "airbrake" # Exception notification
# gem 'soulmate', :git => 'git://github.com/seatgeek/soulmate.git' # Redis based autocomplete storage
gem 'pusher' # pusher publish/subscribe system
gem 'mixpanel' # analytics
gem 'urbanairship' # push notifications
gem 'backbone-on-rails'
gem 'rabl', "0.6.0"
gem 'capistrano'
gem 'rake'

group :assets do
  gem 'sass-rails', '3.2.3'
  gem 'coffee-rails', "3.2.1"
  gem 'compass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  #gem 'therubyrhino'

  gem 'closure-compiler'

  gem 'anjlab-bootstrap-rails', '>= 2.0', :require => 'bootstrap-rails'
end

group :development do
  gem "pry"
  #gem 'rspec-rails'
  #gem 'rspec-cells'
  #gem 'guard'
  #gem 'guard-rspec'
  # gem "ruby-debug"
end

group :test do
  #gem 'rspec'
  #gem "capybara"
  #gem "factory_girl_rails"
  #gem 'growl'
  #gem 'rb-fsevent'
  #gem "database_cleaner"
  #gem "mongoid-rspec"
  #gem "spork", "> 0.9.0.rc"
  #gem 'guard-spork'
  #gem "cucumber-rails"
end

platforms :ruby do
  gem 'yajl-ruby' # json processing
  gem 'dalli' # memcache
  gem 'bson_ext'
  gem 'rmagick', :require => false # Image manipulation (put rmagick at the bottom because it's a little bitch about everything) #McM: lol
  gem 'hirefireapp' # Heroku web/worker auto scaling hirefireapp.com
  gem 'heroku'
  gem 'rpm_contrib', '2.1.7' # extra instrumentation for the new relic rpm agent
  gem 'newrelic_rpm' # performance / server monitoring

  group :production, :staging do
    gem 'thin'
  end

  group :development do
    gem 'heroku_san'
    gem "foreman"
  end
end

platforms :jruby do
  gem 'therubyrhino'
  gem 'json-jruby'
  gem 'jruby-openssl'
  gem 'bson'
  gem 'rmagick4j' # Image manipulation (put rmagick at the bottom because it's a little bitch about everything) #McM: lol
  gem "torquebox-rake-support", '2.0.0.cr1'
  gem 'torquebox-capistrano-support', '2.0.0.cr1'	
  gem "torquebox", '2.0.0.cr1'
end