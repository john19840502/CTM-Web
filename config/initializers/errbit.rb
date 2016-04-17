
if Rails.env.development? || Rails.env.trid_uat?
  api_key = '61136eee1b27692584fc3fc27cd2429a' 
  host = 'ctmerrors.ctmdev.lab'
else
  api_key = 'e76b22cbb469c1b0e01ca7afdc62ab7d'
  host = 'ctmerrors.corp.ctmtg.com'
end

Airbrake.configure do |config|
  config.api_key	= api_key
  config.host    = host
  config.port    = 80
  config.secure  = config.port == 443
end
