class Bpm::LoanValidationFactTypeValue < ActiveRecord::Base
  belongs_to :loan_validation_flow
  belongs_to :loan_validation_fact_type
end
