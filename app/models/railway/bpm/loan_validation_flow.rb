class Bpm::LoanValidationFlow < ActiveRecord::Base
  belongs_to :loan_validation_event
  has_many :loan_validation_event_messages
  has_many :loan_validation_fact_type_values
end
