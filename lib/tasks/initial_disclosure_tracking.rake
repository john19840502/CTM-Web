namespace :loan do

  desc "Hide queue items that have been completed due to changes in data"
  task :clear_completed_trackings => :environment do
    trackings = InitialDisclosureTracking.where {
      (visible == true) & (wq_loan_status.in(["Completed", "Rejected"]))
    }

    trackings.each &:update_visibility!
  end

  desc "update_queue_day_0"
  task :update_queue_day_0 => :environment do
    loans = Master::Loan.trid_loans.
      joins{initial_disclosure_tracking.outer}.
      where { (initial_disclosure_tracking.id == nil) }

    dt = Rails.env.development? ? Date.new(2015,6,28) : Date.current
  
    rls = loans.all_retail_with_test.
      where('application_date >= ? AND application_date < ?', dt.beginning_of_day, dt.end_of_day)
    wls = loans.wholesale_with_test.
      where('interviewer_application_signed_at >= ? AND interviewer_application_signed_at < ?', dt.beginning_of_day, dt.end_of_day)

    loans_day_zero = rls + wls

    InitialDisclosureTracking.insert_loans loans_day_zero

    InitialDisclosureTracking.notify_los
  end
end

desc "fix QA work queue by hiding old loans"
task :cleanup_qa_work_queue => :environment do
  unless Rails.env.qa?
    puts "This task only runs in QA"
    next
  end

  normal_loans = InitialDisclosureTracking.loans_visible_in_queue
  stupid_loans = InitialDisclosureTracking.stupid_loans

  loans = stupid_loans.concat normal_loans
  old = loans.select {|l| d = l.application_date || l.interviewer_application_signed_at; d.present? && d < 1.week.ago }
  to_clear = old.select{|l| l.initial_disclosure_tracking.nil? || l.initial_disclosure_tracking.visible }

  to_clear.each do |l|
    puts "clearing loan #{l.loan_num}"
    t = l.initial_disclosure_tracking || l.build_initial_disclosure_tracking
    t.visible = false

    # have to flag the loan as having its email sent already, or we will send a huge batch of emails and IT will yell at us.  
    t.welcome_email_sent_at = Time.new(2011, 11, 11, 11, 11, 11)
    t.save!
  end

end
