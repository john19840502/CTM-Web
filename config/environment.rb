# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
CtmdbWeb::Application.initialize!

unless Rails.env.test?
  CASClient::Frameworks::Rails::Filter.configure(
    :cas_base_url => CTMAUTH_URL,
    :logger => Rails.logger,
  ) 
end
ActiveResource::Base.logger = ActiveRecord::Base.logger
