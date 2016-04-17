class LoanFactDaily < DatabaseDatamartReadonly
  CREATE_VIEW_SQL =  <<-eos
      SELECT
        LoanNum as id,
        BranchID as institution_number,
        BranchName as institution_name,
        BorrLastName as borrower_last_name,
        BorrFirstName as borrower_first_name,
        PropertyStreetAddress as property_street_address,
        PropertyState as property_state,
        PropertyCity as property_city,
        PropertyCounty as property_county,
        PropertyZIP as property_zip,
        LOLoginName as lo_login_name,
        LOFirstName as lo_first_name,
        LOLastName as lo_last_name,
        AreaManager as area_manager,
        Channel as channel,
        ProductCode as product_code,
        CreatedInAvistaDate as created_in_avista_at,
        Signed1003Date as signed_1003_at,
        LockDate as locked_at,
        LockExpirationDate as lock_expiration_at,
        lfd.LoanStatus as loan_status,
        UWStatus as uw_statue,
        UWStatusDate as uw_status_at,
        UW_Submit_Date as uw_submit_at,
        UWReceivedDate as uw_received_at,
        UWCondApprovalDate as uw_cond_approval_at,
        UWFinalApprovalDate as uw_final_approval_at,
        UnderwriterName as uw_name,
        AUSubmittedDate as au_submitted_at,
        UWSuspendedDate as uw_suspended_at,
        UWDeniedDate as uw_denied_at,
        CancelWithdrawnDate as cancel_withdrawn_at,
        ClosingRequestDate as closing_request_at,
        ClosingDate as closing_at,
        DisbursementDate as disbursement_at,
        _FundedDate as funded_at,
        DocsOutDate as docs_out_at,
        ClosingPkgReceivedDate as closing_pkg_received_at,
        ShippedToInvDate as shipped_to_investor_at,
        InvSuspendedDate as investor_suspended_at,
        PurchasedByInvestorDate as purchased_by_investor_at,
        InvestorName as investor_name,
        LoanUnit as loan_unit,
        FundedUnit as is_funded,
        SoldUnit as is_sold,
        LoanAmount as loan_amount,
        FundedLoanAmount as funded_loan_amount,
        SoldLoanAmount as sold_loan_amount,
        FinalNoteRate as final_note_rate,
        NetPrice as net_price,
        DaysToShip as days_to_ship,
        DaysShipToSell as days_ship_to_sell,
        DaysFundToSell as days_fund_to_sell,
        FICO as fico,
        DTI as dti,
        LTV as ltv,
        AppraisedValue as appraised_value,
        SalePrice as sale_price,
        UWCondPendingDate as uw_cond_pending_at,
        CancelledPostponedDate as cancelled_postponed_at,
        FundingRequestDate as funding_request_at,
        EscrowWaiverIndicator as escrow_waiver_indicator,
        p._Type as loan_purpose_type
      FROM       LENDER_LOAN_SERVICE.dbo.[LoanFact_Daily] as lfd
      LEFT OUTER JOIN LENDER_LOAN_SERVICE.dbo.[LOAN_GENERAL] as lg ON lg.LenderRegistrationIdentifier = LoanNum
      LEFT OUTER JOIN LENDER_LOAN_SERVICE.dbo.[LOAN_PURPOSE] as p ON p.loanGeneral_Id = lg.loanGeneral_Id
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  belongs_to :branch, class_name: 'Institution', primary_key: :institution_number, foreign_key: :institution_number
  belongs_to :loan_general, foreign_key: :id, primary_key: :loan_id

  #####
  # Scopes
  #####

  scope :funded, where(is_funded: true)
  scope :unfunded, where(is_funded: false)

  scope :for_branch_id, lambda { |bid| where(:institution_number => bid) }

  scope :sold, where(is_sold: true)
  scope :unsold, where(is_sold: false)

  scope :funded_between,  lambda {|start_date, end_date| where(funded_at: start_date..end_date) }
  scope :locked_between,  lambda {|start_date, end_date| where(locked_at: start_date..end_date) }
  scope :submitted_between,  lambda {|start_date, end_date| where(uw_submit_at: start_date..end_date) }
  scope :created_in_avista_between,  lambda {|start_date, end_date| where(created_in_avista_at: start_date..end_date) }

  scope :funded_locked_submitted_between,  (lambda do |start_date, end_date|
    where{ uw_submit_at.in(start_date..end_date) | funded_at.in(start_date..end_date) | locked_at.in(start_date..end_date) }
  end)

  scope :affiliate, where(channel: Channel.retail_all_ids)
  scope :wholesale, where(channel: Channel.wholesale.identifier)
  scope :reimbursement, where(channel: Channel.reimbursement.identifier)

  scope :active_pipeline, where(loan_status: LoanPipeline::ACTIVE_PIPELINE)
  scope :inactive_pipeline, where(loan_status: LoanPipeline::INACTIVE_PIPELINE)

  scope :locked_as_of, (lambda do |dt|
    where{ (locked_at != nil) & ((lock_expiration_at == nil) | (lock_expiration_at > dt.to_date.beginning_of_day)) }
  end)

  scope :floating_as_of, (lambda do |dt|
    where{ (locked_at == nil) | ((locked_at != nil) & (lock_expiration_at < dt.to_date.beginning_of_day)) }
  end)

  scope :exclude_prequalifications, where { (property_street_address.not_like('%tbd%')) & (property_city.not_like('%tbd%')) }

  scope :exclude_hmda, joins{ loan_general.denial_letter.outer }.where{ (loan_general.denial_letter.denied_at == nil) & (loan_general.denial_letter.mailed_at == nil) & (loan_general.denial_letter.cancel_withdrawn_at == nil) }

  def branch_name
    institution_name.blank? ? 'N/A' : institution_name
  end

  def is_purchase?
    loan_purpose_type.downcase == 'purchase'
  end

  def is_refi?
    loan_purpose_type.downcase == 'refinance'
  end


  # Because there seems to be a difference in what 'locked' means. These are the definitions
  # provided to me.
  def self.locked_between_eod(start_date, end_date) # eod = end of day
    where{(locked_at >> (start_date.beginning_of_day..end_date.end_of_day)) & (lock_expiration_at > Date.yesterday.end_of_day) }
  end
  def self.locked_yesterday
    locked_between_eod(Date.yesterday, Date.yesterday)
  end

  def self.locked_mtd
    locked_between_eod(Date.today.beginning_of_month, Date.yesterday)
  end

  def self.locked_ytd
    locked_between_eod(Date.today.beginning_of_year, Date.yesterday)
  end
end
