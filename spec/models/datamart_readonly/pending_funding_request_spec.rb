require "spec_helper"

describe PendingFundingRequest do
  smoke_test :loan_id
  smoke_test :borrower_last_name
  smoke_test :request_received_at
  smoke_test :disbursed_at
  smoke_test :loan_type
end
