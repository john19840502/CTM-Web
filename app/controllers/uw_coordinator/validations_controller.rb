class UwCoordinator::ValidationsController < RestrictedAccessController
  def index
  end

  def search
    id = params[:loan_id]

    if id.present?
      redirect_to uw_coordinator_validation_path(id, format: :html)
    else
      flash[:error] = "Please enter a Loan ID"
      redirect_to uw_coordinator_validations_path
    end
  end

  def show
    @loan = Loan.find_by_loan_num(params[:id])
    
    unless @loan and @loan.can_see_loan?(current_user)
      flash[:error] = "Loan #{params[:id]} not found or you are not allowed to view it."
      redirect_to uw_coordinator_validations_path and return
    else
      @uw_registration_validation = @loan.uw_registration_validation || UwRegistrationValidation.new #(user_id: current_user.id, loan_id: @loan.loan_num)
      unless @uw_registration_validation.user_id.present?
        @uw_registration_validation.user_id = current_user.id
        @uw_registration_validation.loan_id = @loan.loan_num
      end

      respond_to do |format|
        format.html do
          @record = @loan
        end
        format.pdf do
          render  :pdf          => "#{@loan.loan_num rescue 'UNKNOWN_LOAN'}_registration_validation",
                  :disposition  => 'attachment',
                  :layout       => 'loan_modelers',
                  :show_as_html => false,
                  :greyscale    => false
        end # render pdf
      end # respond_to
    end # if
  end # show

  def process_registration_validation_alert
    @record = ValidationAlert.where(user_id: current_user.uuid, loan_id: params[:lid], rule_id: params[:rid], alert_type: 'underwriter').first_or_create!
    if @record.valid?
      js = ''
      js << "$('.alert-warning').hide();"
      js << '$("#msg' + @record.rule_id.to_s + ' a").replaceWith("Completed by ' + "#{@record.user_name}" + ' on ' + @record.updated_at.strftime('%m/%d/%Y') + ' :: ");'
      js << '$("#msg' + @record.rule_id.to_s + '").attr("style", "background: url(/assets/icon_sets/famfamfam_silk/icons/flag_green.png) left center no-repeat;padding-left: 20px;");'
      js << "$('.alert-warning').fadeIn('slow');"

      render js: js
    else
      render js: @record.errors.values
    end      
  end

  def process_registration_validation_save
    @record = UwRegistrationValidation.save(params)

    render partial: 'save_message', locals: { record: @record }
  end
end
