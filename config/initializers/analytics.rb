analytics_config = YAML.load_file("#{Rails.root}/config/analytics.yml")
Rails.configuration.analytics_siteid   = analytics_config[Rails.env]['siteid']
Rails.configuration.analytics_hostname = analytics_config[Rails.env]['hostname']
Rails.configuration.analytics_path     = analytics_config[Rails.env]['path']