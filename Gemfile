require 'rbconfig'
source 'http://rubygems.org'

gem 'rails', '3.2.3'
gem 'execjs'
gem 'jquery-rails'
gem 'rack'
gem 'rack-contrib'
gem 'bson_ext'
gem 'mongoid' # MongoDB
gem 'mongoid_slug' # Automatic MongoDB slugs
gem 'mongoid_auto_inc' # Auto incrementing fields in mongoid
gem 'devise' # Authentication
gem 'koala', '1.4.1' # facebook graph api support
gem 'twitter' # twitter api support
gem "omniauth"
gem "omniauth-facebook"
gem 'omniauth-twitter'
gem 'yajl-ruby' # json processing
gem 'heroku'
gem 'resque', '1.20.0'#, :git => 'https://github.com/hone/resque.git', :branch => 'heroku'
gem 'resque-scheduler', '2.0.0.h' # scheduled resque jobs
gem 'resque-loner' # Unique resque jobs
gem "geocoder"
gem "chronic" # Date/Time management
gem 'cancan' # authorization
gem "airbrake" # Exception notification
gem 'rpm_contrib', '2.1.9' # extra instrumentation for the new relic rpm agent
gem 'newrelic-redis', '1.2.0' # new relic redis instrumentation
gem 'newrelic-faraday'
gem 'soulmate', '0.1.3'#:git => 'git://github.com/seatgeek/soulmate.git' # Redis based autocomplete storage
gem 'dalli' # memcache
gem 'pusher' # pusher publish/subscribe system
gem 'mixpanel' # analytics
gem 'urbanairship' # push notifications
gem 'backbone-on-rails'

group :assets do
  gem 'sass-rails', '3.2.3'
  gem 'coffee-rails', "3.2.1"
  gem 'compass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  #gem 'therubyrhino'

  gem 'uglifier'

  gem 'anjlab-bootstrap-rails', '>= 2.0', :require => 'bootstrap-rails'
end

group :production, :staging do
  gem 'thin'
end

group :development do
  gem 'heroku_san'
  gem "pry"
  gem 'rspec-rails'
  gem 'rspec-cells'
  gem 'guard'
  gem 'guard-rspec'
  gem "rails-footnotes"
  gem "ruby-debug19"
  gem "foreman"
end

group :test do
  gem 'rspec'
  gem "capybara"
  gem "factory_girl_rails"
  gem 'growl'
  gem 'rb-fsevent'
  gem "database_cleaner"
  gem "mongoid-rspec"
  gem "spork", "> 0.9.0.rc"
  gem 'guard-spork'
  #gem "cucumber-rails"
end

gem 'rmagick', :require => false # Image manipulation (put rmagick at the bottom because it's a little bitch about everything)