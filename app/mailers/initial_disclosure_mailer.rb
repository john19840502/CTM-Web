class InitialDisclosureMailer < ActionMailer::Base

  default from: 'MBLEReview@mbmortgage.com'
  TO_EMAIL = ['MB Test Broker Reminders <MBTestBrokerReminders@mbmortgage.com>']

  def email_day_0_retail_request loan
    @subj = "#{loan.borrowers.primary.last_name} xxxx#{loan.loan_num.last(4)} - Please Request Disclosures Immediately"

    @to_email = Rails.env.production? ? broker_email(loan) : TO_EMAIL

    mail(to: @to_email, subject: @subj) do |format|
      format.text
      format.html { render layout: 'email' }
    end
  end

  def email_day_0_wholesale_request loan
    @subj = "#{loan.borrowers.primary.last_name} xxxx#{loan.loan_num.last(4)} - Please Request Disclosures Immediately"

    @to_email = Rails.env.production? ? [ broker_email(loan), area_manager_email(loan) ] : TO_EMAIL

    mail(to: @to_email, subject: @subj) do |format|
      format.text
      format.html { render layout: 'email' }
    end
  end

  private

  def broker_email loan
    email = Email::Postman.choose_valid_email(loan.broker_email_address, 'Broker Email not on file <MBLEReview@mbmortgage.com>')

    "#{loan.broker_first_name} #{loan.broker_last_name} <#{email}>"
  end

  def branch_manager_email loan
    bm = loan.branch.try(:branch_manager)
    email = Email::Postman.choose_valid_email(bm.try(:email), 'Branch Manager Email not on file <MBLEReview@mbmortgage.com>')

    "#{bm.try(:name)} <#{email}>"
  end

  def area_manager_email loan
    m = loan.branch.try(:area_manager)
    email = Email::Postman.choose_valid_email(m.try(:email), 'Area Manager Email not on file <MBLEReview@mbmortgage.com>')

    "#{m.try(:name)} <#{email}>"
  end
end
