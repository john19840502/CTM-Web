# # Schedule our monthly MERS exports for the prior months activity
# # every :month, :on => '10th', :at => :midnight do
# # http://stackoverflow.com/questions/6453618/rails-whenever-gem-each-month-on-the-20th
# every '0 0 10 * *' do
#   # LOGIC HERE
# end

# to run it is developement: bundle exec whenever --set 'environment=development' -w

set :output, "#{path}/log/cron.log"
env :PATH, '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'

# it will update every loan's current loan officer to make sure we know if any changes were made to the originator
# every 1.day, at: "5:00 AM" do
#   rake 'ctm:loan:update_loan_officer_audit'
# end

every :weekday, at: '7:00 AM' do
  rake 'ctm:tss_status_report'
end

# Loan Daily Pipeline Reports, Only run on weekdays
every :weekday, at: '5:00 AM' do
  rake 'ctm:run_daily_reports'
end

# Validate all loans
every :weekday, at: '2:00 AM' do
  rake 'ctm:run_loan_validation'
end

# Courtesy Loan  Lock Expiration Reminder 
every :day, at: '5:00 AM' do
  rake 'loan:lock_expiration_emails_routine'
end

# loans_not_submitted_within_14_days
every :day, at: '5:00 AM' do
  rake 'loan:loans_not_submitted_within_14_days'
end

## add loans to queue and send emails to LOs
#every :day, at: '5:00 AM' do
#  rake 'loan:initial_disclosure_tracking'
#end

# add loans to queue and send emails to LOs
every 15.minutes do
 rake 'loan:update_queue_day_0'
end

# check for completed or rejected things, and hide them if their 
# mortgagebot conditions are met
every 10.minutes do
  rake 'loan:clear_completed_trackings'
end

## send emails for wholesale after 1 pm on 2nd day
#every :day, at: '1:10 PM' do
#  rake 'loan:send_email_day_2_and_beyond_after_1_pm_wholesale'
#end

# builds loi and sends to wilmington
every :weekday, at: '3:00 AM' do
  rake 'build_loi'
end

every :weekday, at: '4:00 AM' do
  rake 'tss:build_loi'
end


# Run notifications for loans ready to board and those ready to be reconciled
every [:sunday, :monday, :tuesday, :wednesday, :thursday], :at => '1am' do
  rake 'ctm:send_notifications'
end

# Tss Purchase advice report runs monthly on the first of the month at 3 am
every '0 3 1 * *' do
  rake 'ctm:run_monthly_reports'
end

# Florida condo perse list monthly download on the first of the month at 2 am
every '0 2 1 * *' do
  rake 'ctm:download_monthly_pdf'
end

# Runs every month at 6am to store the calculated data for settlement agents
every '0 6 1 * *' do
  rake 'ctm:store_monthly_settlement_agent_data'
end

every :sunday, :at => '2am' do
  rake 'ctm:run_weekly_reports'
end

# Run Esign imports every 15 minutes during weekdays
every '*/15 6-19 * * 1-5' do
  rake 'esign:update:all'
end

#Run Esign imports once a day during weekends
every [:saturday, :sunday], :at => '6am' do
  rake 'esign:update:all'
end

#Run Forced Registration processing at midnight each day
#every :day, at: '12:00 AM' do
#  rake 'loan:forced_registration_processing'
#end

#Run Forced Registration processing at noon each weekday
#every :weekday, at: '12:00 PM' do
#  rake 'loan:forced_registration_processing'
#end

