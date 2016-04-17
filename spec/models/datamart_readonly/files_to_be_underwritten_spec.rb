require "spec_helper"

describe FilesToBeUnderwritten do
  smoke_test :purpose
  smoke_test :channel
  smoke_test :submitted_at
  smoke_test :age
  smoke_test :received_at
  smoke_test :loan_num
  smoke_test :borrower
  smoke_test :mortgage_type
  smoke_test :product_code
  smoke_test :underwriter_name
  smoke_test :status
end
