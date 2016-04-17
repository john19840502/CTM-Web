class Registration::ValidationsController < RestrictedAccessController
	def index
	end

	def search
    @loan = Loan.find_by(loan_num: params[:id]) || TestLoan.find_by(loan_num: params[:id])

    if @loan.nil? || !@loan.can_see_loan?(current_user) 
      respond_to do |format|
        format.json { render :json => { error: 'Loan not found', success: false}, status: :not_found }
      end
    else
      ft_names = @loan.trid_loan? ? [ "E Consent Indicator" ] : []
      ft_names += [ "Type of Veteran", "VA Homebuyer Usage Indicator" ] if @loan.is_va?
      @manual_fact_types = ManualFactType.build_form_definitions(@loan, ft_names)
      @signature_dates_match = @loan.signature_dates_match?

      # Need the explicit respond_to block instead of just falling back on defaults 
      # so that the exception handler gets triggered if there is a rendering error.
      # Surely there is a more rails-y way to do this??!
#      respond_to do |format|
#        format.json
#      end
    end
#  rescue Exception => e
#    Rails.logger.error ExceptionFormatter.new(e)
#    render json: { error: e.message }, status: 500
  end

end
