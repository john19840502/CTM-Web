class DataCompareController < ApplicationController

  def show
    loan = Loan.find_by(loan_num: params[:id]) || TestLoan.find_by(loan_num: params[:id])
    render json: BuildDataCompare.call(loan)
  rescue => e
    handle_json_error_response e
  end

end
