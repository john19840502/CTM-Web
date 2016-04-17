class InitialDisclosureTracking < DatabaseRailway
  audited

  belongs_to :loan, class_name: 'Master::Loan', primary_key: :loan_num, foreign_key: :loan_num
  belongs_to :branch, class_name: 'Institution', primary_key: :branch_id, foreign_key: :loan_num
  validates :loan_num, uniqueness: :true

  STATUS_VALUES = ['Completed', 'Rejected', 'On Hold', 'Non-TRID' ]

  #TODO:  stop including test loans in this list.  It's only here because they are only 
  #making test loans in the trid uat environment despite the fact that we keep telling 
  #them that test loans do not work.

  CHANNELS = [
    Channel.retail_all_ids,
    Channel.wholesale.identifier,
    "TA0-Test Affiliate Standard", 
    "TP0-Test Private Banking channels", 
    "TC0-Test Consumer Direct Standard",
    "TW0-Test Wholesale Standard",
  ].flatten

  def self.loans_visible_in_queue
    visible_in_queue Master::Loan.trid_loans
  end

  def self.stupid_loans
    # Sometimes MortgageBot fails to add an application_date for loans that should have one,
    # so we add loans like that to this queue as well so our users can fix them.  Hopefully
    # we will be able to delete this code once Mbot gets their act together.  
    visible_in_queue Master::Loan.has_six_pieces.no_app_date.created_post_trid
  end

  def self.visible_in_queue loans
    tbl = InitialDisclosureTracking.table_name
    m = Master::Loan.table_name
    loans.
      includes(:initial_disclosure_tracking).references(:initial_disclosure_tracking).
      where( "channel in (?) AND (#{tbl}.visible IS NULL OR #{tbl}.visible = 1)", CHANNELS).
      order("#{m}.application_date asc, #{m}.interviewer_application_signed_at asc")
  end

  def self.insert_loans loans
    Rails.logger.debug "Inserting InitialDisclosureTrackings for these loans: #{loans.map(&:loan_num)}"
    loans.each do |loan|
      next if loan.initial_disclosure_tracking.present?
      loan.create_initial_disclosure_tracking!
    end
  end

  def self.notify_los
    InitialDisclosureTracking.where(welcome_email_sent_at: nil).each do |l|
      begin
        if l.loan.channel.in?(Channel.retail_all_ids)
          message = InitialDisclosureMailer.email_day_0_retail_request(l.loan)
        else
          message = InitialDisclosureMailer.email_day_0_wholesale_request(l.loan)
        end
        Email::Postman.call message
        l.welcome_email_sent_at = Time.now
        l.save!
      rescue => e
        Rails.logger.error ExceptionFormatter.new(e)
        Airbrake.notify e
      end
    end
  end

  def update_visibility!
    case wq_loan_status
    when 'Completed'
      self.visible = false if disclosure_request_complete?
    when 'Rejected'
      self.visible = false if (loan.pipeline_loan_status_description == "Cancelled" && loan_archived?)
    when 'Non-TRID'
      self.visible = false
    else
      self.visible = true
    end

    save! if changed?
  end

  private

  def loan_archived?
    LoanGeneral.find_by(id: loan.id).loan_events.where("event_description like '%Archived%' ").any?
  end

  def disclosure_request_complete?
    loan.broker_requested_documents? &&
      loan.initial_disclosure_request_completed? &&
      loan.docmagic_disclosure_request_created?
  end
end
