namespace :ctm  do

  desc "Run all daily reports"
  task :run_daily_reports => :environment do
    RegoReport.generate_report
    Tss::Reports::EscrowReport.generate_report
    Tss::Reports::TssAccountingReport.generate_report
    Tss::Reports::ActiveContractsReport.generate_report
    Tss::Reports::BoardingReport.generate_report
  end

  desc "Run daily validations"
  task :run_loan_validation => :environment do
    begin
      puts 'Starting the validations...'
      Decisions::Validator.validate_loans
      puts 'Completed daily validations.'
      Email::Postman.call Notifier.nightly_run_validation_job
    rescue Exception => e
      puts 'Failed validations due to'
      puts e.message
      Email::Postman.call Notifier.nightly_run_validation_failure(e.message)
    end
  end

  desc "Send TSS Status Report"
  task :tss_status_report => :environment do
    Tss::StatusReportWriter.new
  end

  desc "Run all monthly reports"
  task :run_monthly_reports => :environment do
    Tss::Reports::PurchaseAdviceReport.generate_report
  end

  desc "Download monthly perse list"
  task :download_monthly_pdf => :environment do
    puts 'Starting to download florida condo...'
    FloridaCondoPdf.download_pdf 
    puts 'Completed.'
  end

  desc "Monthly store the Settlement Agent Calculated data"
  task :store_monthly_settlement_agent_data => :environment do
    puts 'Starting to save the calculated data...'
    SettlementAgentMonthlyCalculation.create_monthly_calculation_entries
    puts 'Completed.'
  end

  desc "Run all weekly reports"
  task :run_weekly_reports => :environment do
  end

  desc 'Send a notification for tss loan statuses'
  task :send_notifications => :environment do
    Email::Postman.call Notifier.unboarded_loans(Tss::Loan.unboarded)
    Email::Postman.call Notifier.reconciled_loans(Tss::Loan.reconciled)
  end

  namespace :loan do
    desc "Run tasks necessary for Regions assignments."
    task :prepare_regions => :environment do
      Rake::Task['ctm:loan:update_regions'].invoke
    end

    desc "Update Regions"
    # Can be used to bulk-update REGION vis-a-vis BRANCHES and STATES

    task :update_regions => :environment do
      puts 'Starting update...'

      REGIONS = ["West", "MA/SE", "NE/MW", "Central"]

      REGIONS.each do |r|
        puts "Region #{r} ---------------"
        reg = Region.where(name: r).first
        reg = Region.create(name: r) unless reg
      end

      puts 'Completed.'
    end

    desc "Seed ProductGuideline table with all current product codes"
    task :seed_product_codes => :environment do
      LoanFactDaily.active_pipeline.exclude_hmda.exclude_prequalifications.map(&:product_code).uniq.each do |pc|
        ProductGuideline.create(product_code: pc) if (!pc.blank? and ProductGuideline.find_by_product_code(pc).nil?)
      end
    end


    # To run this task, envoke the following line while replacing your_file_name with the real file name
    # bundle exec rake "ctm:loan:get_ltv_cltv_fico[your_file_name.csv]"
    desc "Get LTV, CLTV, and FICO"  
    task :get_ltv_cltv_fico, [:file_name] => :environment do |t, args|
      CSV.open('ltv_cltv_fico_extract.csv', "w") do |csv|
        csv << [ "Loan Num", 
                  "LTV", 
                  "CLTV", 
                  "Lowest FICO", 
                  "Resubordinate Mortgage Loan",
                  "Loan Type",
                  "Product Code",
                  "Subordinate Lien Amount",
                  "MI and Funding Fee Total",
                  "Base Loan Amount",
                  "Property Estimated Value",
                  "Purchase Price"
                ]

        csv_text = File.read(args.file_name)
        loans = CSV.parse(csv_text, :headers => true)

        loans = loans[1..100] unless Rails.env.production?

        loans.each do |row|
          l = Loan.where(loan_num: row["LoanNum"]).take
          if l.nil?
            csv << [row["LoanNum"],'','','']
          else
            csv << [
              l.loan_num,
              (l.ltv rescue 'err'),
              (l.cltv rescue 'err'),
              (LowestFicoScore.new(l.pe_credit_scores).call rescue 'err'),
              (l.liabilities.resubordinate_mortgage_loan rescue 'err'),
              (l.loan_general.loan_type rescue 'err'),
              (l.loan_general.product_code rescue 'err'),
              (l.loan_general.subordinate_lien_amount rescue 'err'),
              (l.mi_and_funding_fee_total_amount rescue 'err'),
              ((l.mortgage_term && l.mortgage_term.base_loan_amount) rescue 'err'),
              ((l.property_appraised_value_amount || l.property_estimated_value_amount) rescue 'err'),
              (l.purchase_price_amount rescue 'err')
            ]
          end
        end
      end
    end

  end

  desc "Clean branch employee institution and title."
  task :clean_employee => :environment do
    users = DatamartUser.retail_employees
    users.each do |user|
      profile = DatamartUserProfile.where(:datamart_user_id => user.id).first
      if profile
        profile.title = nil
        profile.institution_id = nil
        profile.save!
      end
    end
  end

  desc "Updates employee title & branch."
  task :update_employee => :environment do
    users = DatamartUser.retail_employees
    users.each do |user|
      mi = MultiInstitution.where(:datamart_user_id => user.id)
      next unless mi # skip if there is no mi data for this user

      profile = DatamartUserProfile.where(:datamart_user_id => user.id).first
      profile = DatamartUserProfile.new(:datamart_user_id => user.id) if profile.blank?
      if mi.count > 1
        unless user.institution_id.blank?
          # use the id we already have
          profile.institution_id = user.institution_id
        end
      else
        mi = mi.first
        if profile
          profile.institution_id = mi.institution_id
        end
      end
      # set their title if we know
      profile.title = 'Loan Officer' if user.is_loan_officer?
      profile.title = 'Processor' if user.is_processor?
      profile.save!
    end
  end
end #ctm