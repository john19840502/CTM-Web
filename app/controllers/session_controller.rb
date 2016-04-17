class SessionController < ApplicationController

  # This controller is not restricted
  # Everyone should be able to logout
  
  def destroy
    @current_user = @extra_attributes = nil
    reset_session
    CASClient::Frameworks::Rails::Filter.logout(self, root_url)
  end
end
