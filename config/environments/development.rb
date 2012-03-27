require 'pusher'
require 'pry'

Pusher.app_id = 11500
Pusher.key = '0312037e2a21f4279d40'
Pusher.secret = 'b0f6cd50d741b26dabbb'

Whoot::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Mixpanel
  config.middleware.use "Mixpanel::Tracker::Middleware", '4ba8c8fe2bdc121f677297cb6381a9a8', :async => true, :insert_js_last => true

  # ActionMailer Config
  # Setup for development - deliveries, errors raised
  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor)
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"
  config.action_mailer.default_url_options = {
          :host => 'localhost:3002'
  }
  config.action_mailer.smtp_settings = {
          :domain => 'thewhoot.com',
          :address => 'smtp.sendgrid.net',
          :port => 587,
          :authentication => :plain,
          :enable_starttls_auto => true,
          #:user_name => ENV['SENDGRID_USERNAME'],
          #:password => ENV['SENDGRID_PASSWORD']
          :user_name => 'app1340105@heroku.com',
          :password => '2nczsq6j'
  }
end