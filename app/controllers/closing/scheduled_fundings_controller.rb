require 'filter_by_date_controller_methods'

class Closing::ScheduledFundingsController < ApplicationController

  include FilterByDateControllerMethods

  private############

  def filter_by_date_label
    "Fundings Scheduled"
  end

  def filter_by_date_model
    ScheduledFunding
  end

  def filter_by_date_columns
    [:id, :borrower_last_name, :loan_purpose, :channel, :property_state, :branch_listing, :borrower_requested_loan_amount, :disbursed_at, :funding_request_note, :note_last_updated_by]
  end
end
