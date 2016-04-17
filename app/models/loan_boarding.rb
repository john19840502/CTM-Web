class LoanBoarding < DatabaseRailway
  belongs_to :loan, class_name: 'Master::Loan', primary_key: :loan_num
  belongs_to :boarding_file

  attr_accessible :loan

  scope :selected_boarding_loans, ->{ where(boarding_file_id: nil) }

  def board_loan
    id.present? ? self.delete : self.save!
  end

end
