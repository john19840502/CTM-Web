class RestrictedAccessController < ApplicationController
  # Cancan access
  # check_authorization
  # authorize_resource

  # load_and_authorize_resource

  # Handle security errors
  rescue_from ActiveScaffold::ActionNotAllowed, :with => :permission_denied

  ActiveScaffold.set_defaults do |config|
    config.security.default_permission = false
  end

  rescue_from CanCan::AccessDenied do |exception|
    permission_denied exception.message
  end

  def permission_denied(message)
    flash[:error] = "#{message}"
    redirect_to unauthorized_url
  end

  def update_navigation_contents
    redirect_to :back 
  rescue
    redirect_to root_path
  end
end