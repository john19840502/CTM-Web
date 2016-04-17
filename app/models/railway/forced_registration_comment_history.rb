class ForcedRegistrationCommentHistory < LoanCommentHistory
  belongs_to :forced_registration, foreign_key: :loan_num, primary_key: :loan_num, class_name: 'ForcedRegistration'  

end
