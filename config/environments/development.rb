CtmdbWeb::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  
  require 'dotenv'
  Dotenv.load

  config.eager_load = false

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Specify the assets host - Hans
  #config.action_controller.asset_host = "http://localhost:3000"

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = ENV['DEBUG_ASSETS'] == "false" ? false : true

  # Services

  # email settings.
  config.action_mailer.default_url_options = { :host => "ctmweb.dev" }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :file
  # config.action_mailer.perform_deliveries  = false


  # config.after_initialize do
  #   Bullet.enable = true
  #   Bullet.alert = true
  #   Bullet.bullet_logger = true
  #   Bullet.console = true
  #   Bullet.rails_logger = true
  #   Bullet.disable_browser_cache = true
  # end
  
end

TRID_DATE = Date.new(2015,6,28)
SERVICES_PATH = 'http://services.ctmtg.com.dev'

# Set debug to true in development - Hans
DEBUG = true
