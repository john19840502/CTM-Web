require 'docmagic'

DOCMAGIC_URL = YAML.load_file("#{Rails.root}/config/docmagic.yml")[Rails.env]['docmagic_url']
DOCMAGIC_ACCOUNT_IDENTIFIER = YAML.load_file("#{Rails.root}/config/docmagic.yml")[Rails.env]['docmagic_acct_id']
DOCMAGIC_ACCOUNT_USER_NAME = YAML.load_file("#{Rails.root}/config/docmagic.yml")[Rails.env]['docmagic_acct_un']
DOCMAGIC_ACCOUNT_PASSWORD = YAML.load_file("#{Rails.root}/config/docmagic.yml")[Rails.env]['docmagic_acct_pw']
