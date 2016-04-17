class Closing::ValidationsController < RestrictedAccessController
	def index
	end

	def search
    @loan = Loan.find_by(loan_num: params[:id]) || TestLoan.find_by(loan_num: params[:id])
    @cd_only = Master::LoanDetails::CustomLoanData.where(loan_num: params[:id]).last

    if @loan.nil? || !@loan.can_see_loan?(current_user) 
      respond_to do |format|
        format.json { render :json => { error: 'Loan not found', success: false}, status: :not_found }
      end
    else
      ft_names = @loan.trid_loan? ? [ "E Consent Indicator" ] : []
      ft_names += [ "Type of Veteran", "VA Homebuyer Usage Indicator" ] if @loan.is_va?
      @manual_fact_types = ManualFactType.build_form_definitions(@loan, ft_names)
    end
  end

  def set_cd_only
    @loan = Loan.find_by(loan_num: params[:id])
    @cd_only = Master::LoanDetails::CustomLoanData.find_or_initialize_by(loan_num: params[:id])

    if @cd_only.try(:disclose_by_cd_at).present?
      @cd_only.disclose_by_cd_at         = nil
      @cd_only.disclose_by_cd_user_uuid  = nil
    else
      @cd_only.loan_num                  = params[:id]
      @cd_only.disclose_by_cd_at         = Time.now
      @cd_only.disclose_by_cd_user_uuid  = current_user.uuid
    end
    @cd_only.save

    render partial: 'shared/search_disclose_by_cd'
  end
end
