require 'filter_by_date_controller_methods'

class Closing::ClosingRequestReceivedsController < RestrictedAccessController

  include FilterByDateControllerMethods

  private###############

  def filter_by_date_label
    'Closing Requests Received'
  end

  def filter_by_date_model
    ClosingRequestReceived
  end

  def filter_by_date_columns
    [:loan_id, :borrower, :branch, :loan_originator, :area_manager, :assigned_to, :loan_purpose, :loan_status, :property_state, :closing_request_received_at, :docs_out_at, :total_hours, :funding_request_received_at, :closed_at, :funded_at, :closing_cancelled_postponed_at, :shipping_received_at, :role]
  end
end
