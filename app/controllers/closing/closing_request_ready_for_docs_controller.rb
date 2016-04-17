class Closing::ClosingRequestReadyForDocsController < ApplicationController
  def index
    data.label   = 'Closing Requests Ready For Docs'
    data.model   = ClosingRequestReadyForDoc
    data.records = ClosingRequestReadyForDoc.by_closing_date_asc
    data.columns = [:loan_id, :purpose, :channel, :status, :borrower_last_name, :branch_name, :state, :requester_submitted_date, :closing_date, :assigned_to]
    respond_to do |format|
      format.html
      format.xls { send_data data.to_xls }
    end
  end

  def channel_counts
    @by_date_info = ClosingRequestReadyForDoc.count_by_date
    @counts_by_channel = ClosingRequestReadyForDoc.counts_by_channel
  end
end
