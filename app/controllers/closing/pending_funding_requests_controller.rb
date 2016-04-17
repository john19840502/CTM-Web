class Closing::PendingFundingRequestsController < RestrictedAccessController

  def index
    data.label = 'Funding Requests Pending'
    data.model = PendingFundingRequest
    data.columns = [:loan_id, :borrower_last_name, :request_received_at, :disbursed_at, :loan_type]
    respond_to do |format|
      format.html
      format.xls { send_data data.to_xls }
    end
  end

end
