class NotifierPreview < ActionMailer::Preview

  def loan_officer_notify_of_intent_to_proceed
    loan = forced_registration
    Notifier.loan_officer_notify_of_intent_to_proceed(loan)
  end

  def loan_officer_notify_of_impending_forced_registration
    loan = forced_registration
    Notifier.loan_officer_notify_of_impending_forced_registration(loan)
  end

  private

  def forced_registration
    loan = Master::Loan.find_by(:loan_num => "1022358")
    loan
  end
end
