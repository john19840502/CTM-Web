require 'exception_formatter'

class Servicing::LoanBoardingsController < ApplicationController

  def index
    # SHOULD BE Mortgage not Bank
    @shippings = Master::Shipping.available_for_boarding
    @selected_boarding_loans_count = LoanBoarding.selected_boarding_loans.count
  end

  def board_loan
    LoanBoarding.find_or_initialize_by_loan_id(params[:id]).board_loan

    render text: LoanBoarding.selected_boarding_loans.count.to_s
  end
end
