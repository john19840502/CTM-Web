module LoanDenialHelper

  def denial_cancel_or_withdrawal_date loan
    loan.denied_at || loan.cancelled_or_withdrawn_at
  end

  def borrower_email loan
    loan.primary_borrower.try!(:email)
  end

  def custom_loan_data loan
    data = loan.custom_loan_data
    return data unless data.nil?
    loan.build_custom_loan_data
    loan.custom_loan_data.save
    loan.custom_loan_data
  end

end
