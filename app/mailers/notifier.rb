class Notifier < ActionMailer::Base

  # Change the info based on environment.
  default from: (Rails.env == 'development' ? 'MB IT Developers_Ann Arbor <MBITDevelopers_AnnArbor@mbmortgage.com>' : 'MBWEB <MBweb-noreply@mbmortgage.com>')

  def send_test_email(emails, email_text)
    @body = email_text
    mail(:to => emails, :subject => "Testing email settings")
  end

  # Send out a notification on unboarded loans.
  def unboarded_loans(loans)
    return unless Rails.env == 'production'
    to_email = 'MB Servicing <MBservicing@mbmortgage.com>'
    subject  = (Rails.env == 'development') ? 'TESTING -- MBWEB/TSS: Boarded Loans Notification' : 'MBWEB/TSS: Boarded Loans Notification'
    @loan_count = loans.count
    return if @loan_count <= 0
    mail(:to => to_email, :subject => subject) do |format|
      format.text
    end
  end

  # Send out a notification on multiple different loan failure types.
  def rejected_loan(loan, options = {})
    to_email = 'MB Servicing <MBservicing@mbmortgage.com>'
    subject  = (Rails.env == 'development') ? "TESTING -- MBWEB/TSS: #{options[:reason]} Loan Notification" : "MBWEB/TSS: #{options[:reason]} Loan Notification"
    @loan = loan
    @options = options
    mail(:to => to_email, :subject => subject) do |format|
      format.text
    end
  end

  def generic_loan_message(loan, options = {})
    to_email = 'MB Servicing <MBservicing@mbmortgage.com>'
    subject = options[:subject] || "MB Loan Notification"
    @options = options
    @loan = loan
    mail(:to => to_email, :subject => subject) do |format|
      format.text
    end
  end

  # loans that have been reconciled.
  def reconciled_loans(loans)
    return unless Rails.env == 'production'
    to_email = 'MB Servicing <MBmsrpurchases@mbmortgage.com>'
    subject  = (Rails.env == 'development') ? 'TESTING -- MBWEB/TSS: Reconciled Loans Notification' : 'MBWEB/TSS: Reconciled Loans Notification'
    @loan_count = loans.count
    return if @loan_count <= 0
    mail(:to => to_email, :subject => subject) do |format|
      format.text
    end
  end

  def nightly_run_validation_job
    to_email = Rails.env.production? ? 'DL_nightly_run_val_success@mbmortgage.com' : ['skulkarni@mbmortgage.com', 'VKozadayev@mbmortgage.com']
    mail(:to => to_email, :subject => "Daily validations job successfully completed [CTMWEB-#{Rails.env}]") do |format|
      format.text
    end
  end

  def nightly_run_validation_failure(exception)
    to_email = 'DL_nightly_run_val_failure@mbmortgage.com'
    @exception = exception
    mail(:to => to_email, :subject => "Daily validations job failed [CTMWEB-#{Rails.env}]") do |format|
      format.text
    end
  end

  def underwriter_validation_error(loan, exception, type = '')
    to_email = 'MB IT Developers_Ann Arbor <MBITDevelopers_AnnArbor@mbmortgage.com>'
    @exception = exception
    @loan = loan
    @type = type

    mail(:to => to_email, :subject => "Error running validations on Underwriter Validation screen")
  end

  def loan_compliance_event_upload_success
    if Rails.env.production?
      to_email = 'MTG Compliance HMDA <mtgcomplianceHMDA@mbmortgage.com>'
      mail(:to => to_email, :subject => "HMDA loan upload has successfully concluded")
    end
  end

  def loan_compliance_event_upload_failure(exception)
    if Rails.env.production?
      to_email = 'MTG Compliance HMDA <mtgcomplianceHMDA@mbmortgage.com>'
      @exception = exception
      mail(:to => to_email, :subject => "HMDA loan upload has failed")
    end
  end

  def loi_file_report_link(boarding_file)
    to_email    = 'DL_loi_file_report_link@mbmortgage.com'
    @bf = boarding_file
    mail(:to => to_email, :subject => "LOI Loans")
  end

  def loi_file_generation(loans, status, msg = '')
    to_email    = ['MBitdevelopers@mbmortgage.com', 'MBitops@mbmortgage.com']
    @loan_count = loans.size
    @status     = status
    @msg        = msg
    mail(:to => to_email, :subject => "LOI File Generation Status")
  end

  def loi_file_status(status, msg = '')
    to_email  = ['MBitdevelopers@mbmortgage.com', 'MBitops@mbmortgage.com']
    @status   = status
    @msg      = msg
    mail(to: to_email, :subject => "LOI FTP #{status == true ? 'Success' : 'Failed'}")
  end

  def loan_lock_expiration_warning(loan, lock, deadline, days_check)
    if Rails.env.production?
      @loan = loan
      @lock = lock.strftime('%m/%d/%Y')
      @deadline = deadline.strftime('%m/%d/%Y %I:%M %p')
      channel = case @loan.channel[0]
                  when 'A'
                    'R'
                  when 'R'
                    'M'
                  else 
                    @loan.channel[0]
                end
      @loan_num = "#{channel}#{@loan.loan_num.split(//).last(5).join('')}"

      @days_check = days_check
      if days_check == 7
        subj_suffix = 'REMINDER 7 day rate lock expiration'
      elsif days_check == 2
        subj_suffix = 'FINAL REMINDER 2 business day rate lock expiration'
      end

      @subj = "#{@loan.try(:primary_borrower).try(:last_name)} #{@loan_num} - COURTESY #{subj_suffix}"

      from = 'MB Courtesy Lock Notification <MBCourtesyLockNotification@mbmortgage.com>'
      email = Email::Postman.choose_valid_email(@loan.originator.email, 'Originator Email not on file <DL_loan_expiration_sent@mbmortgage.com>')
      to_email = "#{@loan.originator.name} <#{email}>"
      mail(from: from, to: to_email, subject: @subj) do |format|
        ### PER w3.org, parts in a multipart MIME message should be in order of increasing preference
        # http://www.w3.org/Protocols/rfc1341/7_2_Multipart.html
        format.text
        format.html { render layout: 'email' }
      end
    end
  end

  def loan_lock_expiration_warnings_sent(total, days_check)
    @total = total

    if days_check == 7
      @subj_suffix = 'REMINDER 7 day rate lock expiration'
    elsif days_check == 2
      @subj_suffix = 'FINAL REMINDER 2 business day rate lock expiration'
    end

    to_email = Rails.env.production? ? 'DL_loan_expiration_sent@mbmortgage.com' : 'vkozadayev@mbmortgage.com'
    mail(:to => to_email, :subject => "SUCCESSFULLY SENT: COURTESY #{@subj_suffix}") do |format|
      ### PER w3.org, parts in a multipart MIME message should be in order of increasing preference
      # http://www.w3.org/Protocols/rfc1341/7_2_Multipart.html
      format.text
      format.html { render layout: 'email' }
    end
  end

  def loans_not_submitted_within_14_days(loans)
    @loans = loans
    to_email = Rails.env.production? ? "DL_loans_not_submitted_within_14_days@mbmortgage.com" : 'sfrost@mbmortgage.com'
    mail(:to => to_email, :bcc => "sfrost@mbmortgage.com", :subject => "Force Registrations Wholesale") do |format|
      format.html { render layout: 'email' }
    end
  end

  def loan_officer_notify_of_intent_to_proceed(loan)
    @loan = loan

    to_email = 'MBTestBrokerReminders@mbmortgage.com'

    mail(:to => to_email, :subject => "Notification of Intent to Proceed for #{loan.loan_num} #{loan.primary_borrower.last_name}") do |format|
      format.html { render layout: 'email' }
    end
  end

  def loan_officer_notify_of_impending_forced_registration(loan)
    @loan = loan

    to_email = 'MBTestBrokerReminders@mbmortgage.com'

    if Channel.retail_all_ids.include?(loan.channel)
      attachments['retail_bulletin.pdf'] = File.read('app/mailers/attachments/forced_registration/retail_bulletin.pdf')
    else
      attachments['wholesale_bulletin.pdf'] = File.read('app/mailers/attachments/forced_registration/wholesale_bulletin.pdf')
    end

    mail(:to => to_email, :subject => "FINAL REMINDER - Registration required for #{loan.loan_num} #{loan.primary_borrower.last_name}") do |format|
      format.html { render layout: 'email' }
    end
  end


end
