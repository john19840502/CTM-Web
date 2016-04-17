class Funding::ValidationsController < RestrictedAccessController
  def index
  end

  def search
    @loan = Loan.find_by(loan_num: params[:id]) || TestLoan.find_by(loan_num: params[:id])

    if @loan.nil? || !@loan.can_see_loan?(current_user)
      respond_to do |format|
        format.json { render :json => { error: "Loan not found", success: false}, status: :not_found}
      end
    else
      render status: :ok, json: @loan
    end
  end

end