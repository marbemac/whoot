require 'rbconfig'
HOST_OS = Config::CONFIG['host_os']
source 'http://rubygems.org'

gem 'rails', '3.1.1.rc3'
gem 'thin'
gem 'execjs'
gem 'jquery-rails'
gem 'bson_ext'
gem 'mongoid' # MongoDB
gem 'mongoid_slug' # Automatic MongoDB slugs
gem 'mongoid_auto_inc' # Auto incrementing fields in mongoid
gem 'devise' # Authentication
gem "omniauth", :git => 'https://github.com/intridea/omniauth', :branch => '0-3-stable' # Social Authentication
gem 'frontend-helpers'
gem 'cells' # Components
gem 'yajl-ruby' # json processing
gem 'redcarpet' # Markdown
gem 'fog' # Cloud support (amazon s3, etc)
gem 'carrierwave' # File uploads
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem 'heroku'
gem 'resque', :require => 'resque/server' # Background jobs
gem 'resque-loner' # Unique resque jobs
gem 'hirefireapp' # Heroku web/worker auto scaling hirefireapp.com
gem "geocoder"
gem "chronic" # Date/Time management
gem 'cancan' # authorization
gem 'formtastic'
gem 'state_select'
gem 'formtastic_state_select'
gem 'activeadmin'
gem "airbrake" # Exception notification
#TODO: the rpm_contrib is being pulled from git because of a bug. Check this pull request and use gem if merged. https://github.com/newrelic/rpm_contrib/pull/13
gem 'rpm_contrib', :git => 'git://github.com/kenn/rpm_contrib.git', :branch => 'mongo140compat' # extra instrumentation for the new relic rpm agent
gem 'newrelic_rpm' # performance / server monitoring

group :assets do
  gem 'compass', '~> 0.12.alpha'
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

group :development do
  gem "pry"
  gem 'rspec-rails'
  gem 'rspec-cells'
  gem 'guard'
  gem 'guard-rspec'
  gem "rails-footnotes"
  gem "ruby-debug19"
  gem "foreman"

  #case HOST_OS
  #  when /darwin/i
  #    gem 'rb-fsevent'
  #    gem 'growl'
  #  when /linux/i
  #    gem 'libnotify'
  #    gem 'rb-inotify'
  #  when /mswin|windows/i
  #    gem 'rb-fchange'
  #    gem 'win32console'
  #    gem 'rb-notifu'
  #end

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