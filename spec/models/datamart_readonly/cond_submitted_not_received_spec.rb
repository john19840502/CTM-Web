require "spec_helper"

describe CondSubmittedNotReceived do
  smoke_test :channel
  smoke_test :purpose
  smoke_test :loan_num
  smoke_test :borrower_last_name
  smoke_test :underwriter_name
  smoke_test :mortgage_type
  smoke_test :product_code
  smoke_test :product_desc
  smoke_test :state
  smoke_test :uw_submitted_at
  smoke_test :age
  smoke_test :pac_condition
  smoke_test :is_jumbo_candidate
  smoke_test :is_mi_required
end
