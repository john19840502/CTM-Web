require "spec_helper"

describe ClosingRequestReceived do
  smoke_test(:loan_id)
  smoke_test(:borrower)
  smoke_test(:branch)
  smoke_test(:loan_originator)
  smoke_test(:area_manager)
  smoke_test(:assigned_to)
  smoke_test(:loan_purpose)
  smoke_test(:loan_status)
  smoke_test(:property_state)
  smoke_test(:closing_request_received_at)
  smoke_test(:docs_out_at)
  smoke_test(:total_hours)
  smoke_test(:funding_request_received_at)
  smoke_test(:closed_at)
  smoke_test(:funded_at)
  smoke_test(:closing_cancelled_postponed_at)
  smoke_test(:shipping_received_at)
  smoke_test(:role)
end
