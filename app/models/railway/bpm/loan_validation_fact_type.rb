class Bpm::LoanValidationFactType < ActiveRecord::Base
  has_many :loan_validation_fact_type_values
end
