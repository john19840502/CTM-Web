class Closing::ClosingRequestsAwaitingReviewsController < RestrictedAccessController
  def index
    data.label = 'Closing Requests Awaiting Review'
    data.model = ClosingRequestsAwaitingReview
    data.columns = [:loan_id, :loan_purpose, :channel, :loan_status, :originator_name, :area_manager, :branch_name, :borrower, :state, :submitted_at, :closing_at, :lock_expire_at, :closing_request_notes, :note_last_updated_by]

    respond_to do |format|
      format.html
      format.xls { send_data data.to_xls }
    end
  end

  def channel_counts
    #info = ClosingRequestsAwaitingReview.counts_by_channel
    @submitted_counts = ClosingRequestsAwaitingReview.counts_by_channel_submitted
    @closing_counts = ClosingRequestsAwaitingReview.counts_by_channel_closed
  end
end
