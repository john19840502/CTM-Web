class LoanCommentHistory < DatabaseRailway
  attr_accessible :comment, :user_action, :user_name

  belongs_to :loan, class_name: 'Master::Loan', foreign_key: :loan_num, primary_key: :loan_num

  scope :forced_registration_comments, ->{ where(type: 'ForcedRegistrationCommentHistory') }
end
