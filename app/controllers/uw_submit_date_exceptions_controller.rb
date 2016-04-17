class UwSubmitDateExceptionsController < ApplicationController
  def index
    data.model = UwSubmitDateException
    data.label = "UW Submit Date Exception Report"
    data.columns = [:loan_id, :channel, :borrower_last_name]
    respond_to do |format|
      format.html
    end
  end
end
