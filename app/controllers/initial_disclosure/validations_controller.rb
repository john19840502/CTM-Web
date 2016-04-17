class InitialDisclosure::ValidationsController < RestrictedAccessController
  
  def index
  end

  def search
    Rails.logger.debug "Searching for loan #{params[:id]}"
    @loan = Loan.find_by_loan_num(params[:id])

    if @loan.nil? || !@loan.can_see_loan?(current_user) 
      respond_to do |format|
        format.json { render :json => { error: 'Loan not found', success: false}, status: :not_found }
      end
    else
      ft_names = @loan.trid_loan? ? [ "Existing Survey Indicator" ] : []
      ft_names += [ "Type of Veteran", "VA Homebuyer Usage Indicator" ] if @loan.is_va?
      @manual_fact_types = ManualFactType.build_form_definitions(@loan, ft_names)

      # Need the explicit respond_to block instead of just falling back on defaults 
      # so that the exception handler gets triggered if there is a rendering error.
      # Surely there is a more rails-y way to do this??!
      respond_to do |format|
        format.json
      end
    end
  rescue Exception => e
    handle_json_error_response e
  end

end
