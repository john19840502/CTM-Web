class Servicing::ManualBoardingController < ApplicationController
  def index
    @pending = Master::Shipping.available_for_boarding
  end

  def find_loans
    loan_numbers = params[:search_for].split(',').collect(&:strip)
    @loans = Master::Loan.where(loan_num: loan_numbers)
    respond_to do |format|
      format.js
    end
  end

  def board
    success_count = 0
    loans = params[:loan_numbers].split(',').uniq
    found_loans = Master::Loan.where(loan_num: loans)
    found_loans.each do |loan|
      success_count += 1 if loan.set_for_boarding
    end
    render text: "#{success_count} of #{found_loans.size} loans set to board."
  end
end
