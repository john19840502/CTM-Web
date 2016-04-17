auth_cfg = YAML.load_file("#{Rails.root}/config/ctmauth.yml")
CTMAUTH_URL = auth_cfg[Rails.env]['base_url']
