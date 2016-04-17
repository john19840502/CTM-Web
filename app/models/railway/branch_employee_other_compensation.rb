class BranchEmployeeOtherCompensation < DatabaseRailway
  belongs_to :branch_employee, foreign_key: :datamart_user_id
  belongs_to :branch, class_name: 'Institution', foreign_key: :institution_id

  validates :datamart_user_id, :effective_date, presence: true
  validates :effective_date, allow_nil: true, allow_blank: true, timeliness: { on_or_after: lambda { (Date.today - 365.days) } }

  validates :effective_date, uniqueness: { scope: :datamart_user_id }

  validate :per_loan_processed_xor_per_loan_branch_processed

private

  def per_loan_processed_xor_per_loan_branch_processed
    unless per_loan_processed.blank? and per_loan_branch_processed.blank?
      errors[:base] << "Can not have Per Loan Processed and Per Branch Loan Processed compensations simultaneously" if !(per_loan_processed.blank? ^ per_loan_branch_processed.blank?)
    end
  end
end
 
