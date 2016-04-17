namespace :loan do
  task :loans_not_submitted_within_14_days => :environment do
    loans = Master::Loan.wholesale.loans_not_submitted_within(14.days.ago)
    message = Notifier.loans_not_submitted_within_14_days(loans)
    Email::Postman.call message
  end

  desc "Notify loan officers of intent to proceed"
  task :notify_loan_officer_of_intent_to_proceed => :environment do
    unsubmitted_loans = Master::Loan.all_but_mini_corr.loans_not_submitted_within(0.days.ago)
    unsubmitted_loans.each do |loan|
      fr_loan = ForcedRegistration.find_by(:loan_num => "#{loan.loan_num}")
      unless fr_loan
        message = Notifier.loan_officer_notify_of_intent_to_proceed(loan)
        Email::Postman.call message
        registration = ForcedRegistration.new(
          :loan_num                         => loan.loan_num,
          :branch                           => Channel.retail_all_ids.include?(loan.channel) ? "#{loan.branch.try(:name).to_s} #{loan.branch.try(:institution_identifier).to_s}" : "N/A",
          :assigned_to                      => "unassigned",
          :user_action                      => "Pending Review",
          :comment                          => "Intent to proceed notification sent to loan officer.",
          :channel                          => loan.channel,
          :product_name                     => loan.product_name,
          :borrower                         => loan.primary_borrower.full_name,
          :loan_officer                     => "#{loan.broker_first_name} #{loan.broker_last_name}",
          :lo_contact_number                => loan.interviewer_telephone,
          :lo_contact_email                 => loan.broker_email_address.to_s,
          :disclosure_date                  => loan.initial_gfe_disclosure_on ? loan.initial_gfe_disclosure_on.strftime('%m/%d/%Y') : nil,
          :loan_status                      => loan.pipeline_loan_status_description,
          :intent_to_proceed_date           => loan.custom_fields.intent_to_proceed_date_string,
          :area_manager                     => Channel.retail_all_ids.include?(loan.channel) ? "N/A" : loan.account_executive_name,
          :institution                      => Channel.retail_all_ids.include?(loan.channel) ? "N/A" : loan.branch.try(:name),
          :state                            => Channel.retail_all_ids.include?(loan.channel) ? "N/A" : loan.property_state,
          :visible                          => false,
          :sent_intent_to_proceed_notice    => true,
          :sent_forced_registration_warning => false
        )
        registration.comments.build(:comment => "Intent to proceed notification sent to loan officer.", :user_action => "Send Intent to Proceed Notice", :user_name => "System")
        registration.save
      end
    end
  end

  desc "Notify loan officers of impending forced registration status"
  task :notify_loan_officer_of_impending_forced_registration => :environment do
    unsubmitted_loans = Master::Loan.all_but_mini_corr.loans_not_submitted_within(12.days.ago)
    unsubmitted_loans.each do |loan|
      fr_loan = ForcedRegistration.find_by(:loan_num => "#{loan.loan_num}")

      if fr_loan && fr_loan.can_send_forced_registration_warning?
        message = Notifier.loan_officer_notify_of_impending_forced_registration(loan)
        Email::Postman.call message

        fr_loan.comment = "12 day notification sent to loan officer."
        fr_loan.sent_forced_registration_warning = true
        fr_loan.comments.build(:comment => "12 day notification sent to loan officer.", :user_action => "Send 12 Day Notification", :user_name => "System")
        fr_loan.save
      end
    end
  end

  desc "Show items that have moved into forced registration status"
  task :show_forced_registrations => :environment do
    unsubmitted_loans = Master::Loan.all_but_mini_corr.loans_not_submitted_within(14.days.ago).pluck(:loan_num)
    unsubmitted_loans.each do |loan_id|
      fr_loan = ForcedRegistration.find_by(:loan_num => "#{loan_id}")

      if fr_loan && !fr_loan.visible
        fr_loan.visible = true
        fr_loan.comment = "Loan 14 days old, displaying in queue"
        fr_loan.comments.build(:comment => "Loan 14 days old, displaying in queue", :user_action => "14 day activation", :user_name => "System")
        fr_loan.save
      end
    end
  end

  desc "Keep data in forced registrations up to date"
  task :update_forced_registrations => :environment do
    ForcedRegistration.keep_updated.each do |fr_loan|
      mloan = Master::Loan.find_by(:loan_num => fr_loan.loan_num)
      sent_email_comment = ''

      fr_loan.disclosure_date = mloan.initial_gfe_disclosure_on
      fr_loan.intent_to_proceed_date = mloan.custom_fields.intent_to_proceed_date_string
      fr_loan.loan_status = mloan.pipeline_loan_status_description

      if fr_loan.changed?
        if fr_loan.intent_to_proceed_date_changed? 
          if fr_loan.intent_age >= 14
            fr_loan.visible = true
          end

          if fr_loan.intent_age < 14
            fr_loan.visible = false
          end

          if fr_loan.intent_age < 12
            fr_loan.sent_forced_registration_warning = false
          end

          #resent intent to proceed notice, since the dates in the first one sent are no longer valid
          message = Notifier.loan_officer_notify_of_intent_to_proceed(mloan)
          Email::Postman.call message

          fr_loan.sent_intent_to_proceed_notice = true

          sent_email_comment = "Intent to proceed notification resent to loan officer because intent to proceed date changed from #{fr_loan.intent_to_proceed_date_was} to #{fr_loan.intent_to_proceed_date}."
        end

        unless ['File Received','New','Imported','In Process'].include?(fr_loan.loan_status)
          fr_loan.visible = false
        end

        update_comment = "Updated values: #{fr_loan.updated_values_to_s}."
        fr_loan.comments.build(:comment => "#{update_comment} #{sent_email_comment}", :user_action => "Update Forced Registration", :user_name => "System")
        fr_loan.save
      end
    end
  end

  desc "Forced Registration Batch Processing"
  task :forced_registration_processing => :environment do
    #update data in the forced registration queue first, so that if we need to re-trigger anything it'll get caught by the normal tasks for that
    sh("rake loan:update_forced_registrations > /dev/null")
    #add any new items to the queue, send itent to proceed received email
    sh("rake loan:notify_loan_officer_of_intent_to_proceed > /dev/null")
    #send the impending forced registration warning
    sh("rake loan:notify_loan_officer_of_impending_forced_registration > /dev/null")
    #show / turn on loans in forced registration that have reached the forced registration date (14 days old)
    sh("rake loan:show_forced_registrations")
  end 
end
