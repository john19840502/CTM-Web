class Qa::LoanFinderController < ApplicationController

  def index
    render 'search'
  end

  def search
    r = Random.new(Time.now.strftime('%s').to_i)
    batch_size = (Loan.where(:channel => params[:channel]).count / 10).floor
    @loans = []
    Loan.where(:channel => params[:channel]).find_in_batches(batch_size: batch_size) do |loans|
      rand_loan = r.rand(batch_size - 1)
      loan = loans[rand_loan].nil? ? loans.last : loans[rand_loan]
      @loans << loan.loan_num
    end
  end

end
