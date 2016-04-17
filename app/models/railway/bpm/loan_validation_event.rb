class Bpm::LoanValidationEvent < DatabaseRailway
  has_many :loan_validation_flows

  belongs_to :loan, class_name: 'Master::Loan', foreign_key: :loan_num, primary_key: :loan_num
end