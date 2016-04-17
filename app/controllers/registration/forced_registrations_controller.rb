class Registration::ForcedRegistrationsController < RestrictedAccessController

  def index
    @loans = ForcedRegistration.current_items
    respond_to :html, :json
  end

  def update
    @loan = ForcedRegistration.find(params[:id])
    params.delete(:_method)

    unless params[:user_action].blank?
      comment = params[:comment].blank? ? "No comment provided by user" : params[:comment]
      user_name = "#{current_user.last_name}, #{current_user.first_name}"
      user_action = params[:user_action]

      @loan.comments.build(:comment => comment, :user_action => user_action, :user_name => user_name)
    end

    @loan.update_attributes(forced_registration_params)
  end

  def search
    @loan = ForcedRegistration.where(:loan_num => params[:loan_num]).first
  end

  def forced_registration_params
    params.permit(:comment, :visible, :user_action, :id, :assigned_to) 
  end
end
