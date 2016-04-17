class NotifierPreview < ActionMailer::Preview

  def loans_not_submitted_within_14_days
    loans = Master::Loan.limit(2)
    Notifier.loans_not_submitted_within_14_days(loans)
  end

end
