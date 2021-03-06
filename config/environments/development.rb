require 'five_d_logger'  
require 'cookie_filter'

IdentityProvider::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Add the cookie filter to the rack middelware. presently the filtering mechanism
  # hasn't been implemented and the cookie filter - middleware class does nothing. 
  # config.middleware.use "CookieFilter"

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address        => "mail.5dlab.com",
    :port           => 587,
    :domain         => "5dlab.com",
    :authentication => :plain,
    :user_name      => "no-reply@5dlab.com",
    :password       => "+N4$3.bQ",
    :enable_starttls_auto => true,
    :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE
  }
  
  # set log level of logger
  config.log_level = ActiveSupport::BufferedLogger::Severity::DEBUG  
  
  config.log_path = 'log/development.log'
  
  # initializing custom logger  
  config.logger = FiveDLogger.new(config.log_path, config.log_level)
  
  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
  
  config.assets.prefix = "/identity_provider/assets"
end
