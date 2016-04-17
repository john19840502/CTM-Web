class Bpm::LoanValidationEventMessage < ActiveRecord::Base
  belongs_to :loan_validation_flow
  belongs_to :loan_validation_message_type
end
