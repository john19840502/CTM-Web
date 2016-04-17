class Bpm::LoanValidationMessageType < ActiveRecord::Base
  has_many :loan_validation_event_messages
end
