namespace :loan do
  desc "Run all loan lock routines"
  task :lock_expiration_emails_routine => :environment do
    if Rails.env.production?
      lock_expiration_emails(7)
      lock_expiration_emails(2) if office_is_open
    end
  end

  LOAN_STATUSES = ['Closing Cancelled/Postponed',
                   'Error',
                   'File Incomplete',
                   'File Received',
                   'Imported',
                   'In Process',
                   'New',
                   'Submit/Error',
                   'Submitted',
                   'U/W Approved w/Conditions',
                   'U/W Conditions Pending Review',
                   'U/W Exception Submitted',
                   'U/W Final Approval/Ready for Docs',
                   'U/W Final Approval/Ready to Fund',
                   'U/W Pre-approval Submitted',
                   'U/W Pre-Approved',
                   'U/W Received',
                   'U/W Submitted',
                   'U/W Suspended',
                   'UW Denied',
                   'UW Pending Second Review']

  # Find all loans with lock expiring in 7 CALENDAR or 2 BUSINESS days and email originators about it
  def lock_expiration_emails(check_days)

    today_date = Rails.env.production? ? Date.today : 2.years.ago

    if check_days == 7
      dt = 7.days.since(today_date)
      dt_start, dt_end = dt, dt
    elsif check_days == 2
      dt_start = 2.days.since(today_date)
      dt_end = 2.business_days.since(today_date)
    end

    loans = Master::Loan.
              where('lock_expiration_at between ? and ?', dt_start.beginning_of_day, dt_end.end_of_day).
              where('pipeline_loan_status_description in (?)', LOAN_STATUSES).
              where('denial_mailed_date is NULL')

    loans.each do |loan|
      lock = calculate_lock_expiration_date(loan.lock_expiration_at)
      # deadline = calculate_prior_mortgage_date(lock)
      deadline = lock.end_of_day

      message = Notifier.loan_lock_expiration_warning(loan, lock, deadline, check_days)
      Email::Postman.call message
      break unless Rails.env.production?
    end

    LoanLockExpirationEmail.new.record_emails(loans, check_days)
    message = Notifier.loan_lock_expiration_warnings_sent(loans.count, check_days)
    Email::Postman.call message

  end

  def calculate_lock_expiration_date(dt)
    if dt.to_date.holiday?(:us)
      1.business_day.before(dt)
    else
      dt
    end
  end

  NOT_MORTGAGE_HOLIDAYS = ['Columbus Day', 'Martin Luther King, Jr. Day', 'Veterans Day']

  def calculate_prior_mortgage_date(dt)
    prior_dt = (dt - 1.day).to_date
    return prior_dt unless prior_dt.holiday?(:us) && !office_is_open(prior_dt)

    return 1.business_day.before(dt)
  end

  def office_is_open(dt = Date.today)
    holiday = dt.holidays(:us)[0]
    return true if dt.workday? || (holiday.present? && holiday[:name].in?(NOT_MORTGAGE_HOLIDAYS))
    return false
  end

end
