require 'rbconfig'
source 'http://rubygems.org'

gem 'rails', '3.2.1'
gem 'execjs'
gem 'jquery-rails'
gem 'bson_ext'
gem 'mongoid' # MongoDB
gem 'mongoid_slug' # Automatic MongoDB slugs
gem 'mongoid_auto_inc' # Auto incrementing fields in mongoid
gem 'devise' # Authentication
gem 'koala' # facebook graph api support
gem "omniauth"
gem "omniauth-facebook"
gem 'cells' # Components
gem 'yajl-ruby' # json processing
gem 'redcarpet' # Markdown
gem 'fog' # Cloud support (amazon s3, etc)
gem 'carrierwave' # File uploads
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem 'heroku'
#gem 'resque', :require => 'resque/server' # Background jobs
gem 'resque', :git => 'https://github.com/hone/resque.git', :branch => 'heroku'
gem 'resque-scheduler', '2.0.0.e' # scheduled resque jobs
gem 'resque-loner' # Unique resque jobs
gem 'hirefireapp' # Heroku web/worker auto scaling hirefireapp.com
gem "geocoder"
gem "chronic" # Date/Time management
gem 'cancan' # authorization
gem 'formtastic'
gem 'state_select'
gem 'formtastic_state_select'
#gem 'activeadmin'
gem "airbrake" # Exception notification
gem 'rpm_contrib' # extra instrumentation for the new relic rpm agent
gem 'newrelic_rpm' # performance / server monitoring
gem 'soulmate' # Redis based autocomplete storage
gem 'dalli' # memcache
gem 'pusher' # pusher publish/subscribe system
gem 'mixpanel' # analytics
gem 'urbanairship' # push notifications

group :assets do
  gem 'compass', '0.12.alpha.4'
  gem 'sass-rails', '3.2.3'
  gem 'coffee-rails', "3.2.1"
  gem 'uglifier', '>= 1.0.3'
end

group :production do
  gem 'unicorn'
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
  gem "cucumber-rails"
end

gem 'rmagick', :require => false # Image manipulation (put rmagick at the bottom because it's a little bitch about everything)