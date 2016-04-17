class InitialDisclosureMailerPreview < ActionMailer::Preview
 
  def email_day_0_retail_request
    idt = add_fake_loan Date.current, Channel.retail.identifier
    InitialDisclosureMailer.email_day_0_retail_request idt
  end
 
  def email_day_0_wholesale_request
    idt = add_fake_loan Date.current, Channel.wholesale.identifier
    InitialDisclosureMailer.email_day_0_wholesale_request idt
  end

private 
  
  def add_fake_loan dt, chanl
    loan = Master::Loan.find_by(loan_num: 1059509)

    loan.channel                   = chanl

    loan
  end
end
