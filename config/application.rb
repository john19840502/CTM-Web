require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

unless Rails.env.test?
  require 'ctmroles-client'
end

module CtmdbWeb
  class Application < Rails::Application

    # we're not using db/schema.rb, and generating it takes forever. 
    config.active_record.dump_schema_after_migration = false

    config.active_record.table_name_prefix = 'ctmweb_'
    config.active_record.table_name_suffix = "_#{Rails.env.downcase}"

    config.generators do |g|
      g.orm :active_record
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(
      #{Rails.root}/app/models/datamart_readonly
      #{Rails.root}/app/models/datamart_readonly/concerns
      #{Rails.root}/app/models/datamart_writeable
      #{Rails.root}/app/models/railway
      #{Rails.root}/app/models/railway/mers
      #{Rails.root}/app/models/tableless
      #{Rails.root}/app/models/form
      #{Rails.root}/app/models/smds
      #{Rails.root}/app/middleware
      #{Rails.root}/app/models/drools
    )
    config.autoload_paths += Dir["#{config.root}/app/queries/**/"]
    config.autoload_paths += Dir["#{config.root}/app/services/**/"]
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    I18n.enforce_available_locales = false

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Load up our middleware stack - Hans
    # config.middleware.use "ResponseTimer", "Load Time"
  end
end
