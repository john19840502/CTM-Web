class Compliance::Hmda::HmdaInvestorCodesController < ApplicationController
  def index
    #hmda_investor_names = HmdaInvestorCode.select(:investor_name).map(&:investor_name).flatten
    #loan_investor_names = Loan.select(:investor_name).uniq.map(&:investor_name)

    @investor_names = HmdaInvestorCode.investor_list
    @hmda_investors = HmdaInvestorCode.all.sort_by &:investor_code
  end

  def update_investor
    investor = params[:investor_name]
    code = params[:investor_code]

    HmdaInvestorCode.update_code(code, investor)

    flash[:success] = "#{investor} investor code was successfully updated to #{code}."
    redirect_to :back
  end

end