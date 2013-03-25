require 'five_d_logger'  

IdentityProvider::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false
  
  #config.assets.prefix = ""

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  config.action_controller.asset_host = "https://backup-round2.wack-a-doo.de/identity_provider"

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # See everything in the log (default is :info)
  config.log_level = ActiveSupport::BufferedLogger::Severity::DEBUG  
  config.log_path = 'log/production.log'
  config.logger = FiveDLogger.new(config.log_path, config.log_level)
  config.active_support.deprecation = :log



  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  #config.assets.precompile += ['client.css', 'identities.css', 'log_entries.css', 'scaffold.css', 'sessions.css']

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_deliveries = false

  config.action_mailer.delivery_method = :smtp
  #config.action_mailer.smtp_settings = {
  #  :address        => "smtp.5dlab.com",
  #  :port           => 587,
  #  :domain         => "5dlab.com",
  #  :authentication => :plain,
  #  :user_name      => "no-reply@5dlab.com",
  #  :password       => "+N4$3.bQ",
  #  :enable_starttls_auto => true,
  #  :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE
  #}
  
  
  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

end
