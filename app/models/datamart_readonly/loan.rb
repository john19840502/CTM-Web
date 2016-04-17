class Loan < DatabaseDatamartReadonly
  include Noteable
  include LoanModeler

  # below is used for modelers.
  include ActionView::Helpers::NumberHelper

  CREATE_VIEW_SQL = <<-eos
      SELECT  LoanNum AS id,
              LoanNum AS loan_num,
              LoanAmount AS loan_amount,
              PropertyStreetAddress AS property_street,
              PropertyState AS property_state,
              PropertyCity AS property_city,
              PropertyCounty AS property_county,
              PropertyZIP AS property_zip,
              AppraisedValue AS appraised_value,
              BorrLastName AS borrower_last_name,
              BorrFirstName AS borrower_first_name,
              Channel AS channel,
              DTI AS debt_to_income_ratio,
              EscrowWaiverIndicator AS is_escrow_waived,
              _FundedDate AS funded_at,
              PurchasedByInvestorDate AS purchased_by_investor_at,
              Signed1003Date AS signed_1003_at,
              LockDate AS locked_at,
              LockExpirationDate AS lock_expiration_at,
              CAST(FundedUnit AS bit) AS is_funded,
              CAST(SoldUnit AS bit) AS is_sold,
              SoldLoanAmount AS sold_loan_amount,
              LoanStatus AS loan_status,
              DisbursementDate AS disbursed_at,
              ClosingDate AS closed_at,
              InvestorName AS investor_name,
              AreaManager AS area_manager,
              UW_Submit_Date AS submit_to_underwriting_date,
              FinalNoteRate as final_note_rate,
              NetPrice as net_price,
              UW_Initial_Decision_Date as initial_decision_date,
              UWFinalApprovalDate as final_approval_date
      FROM  LENDER_LOAN_SERVICE.dbo.vwLoanFact
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  #Sqlserver does not have a native date data type, only datetime.
  # CTMWEB-911
  coerce_sqlserver_date :funded_at, :purchased_by_investor_at, :signed_1003_at,
    :locked_at, :lock_expiration_at, :disbursed_at, :closed_at

  # aliased attributes
  alias_attribute :name, :loan_num
  alias_attribute :amount, :loan_amount
  alias_attribute :note_at, :closed_at
  alias_attribute :note_date, :closed_at


  ####
  # Associations
  ####

  has_many :borrowers
  has_many :settlement_agent_audits
  has_many :settlement_agent_trid_audits
  has_many :service_orders
  has_one  :last_settlement_agent_audit, -> { order "created_at DESC"} , class_name: 'SettlementAgentAudit'
  has_one  :last_settlement_agent_trid_audit, -> { order "id DESC" } , class_name: 'SettlementAgentTridAudit'
  has_one  :broker_comp_modeler
  has_one  :closing_request_ready_for_doc
  has_one  :closing_requests_awaiting_review
  has_one  :dodd_frank_modeler
  has_one  :freddie_relief_modeler
  has_one  :funding_modeler
  has_one  :interviewer
  has_many  :loan_boardings
  has_one  :loan_general
  has_one  :locked_loan_snapshot
  has_one  :smds_jumbo_fixed_loan, :class_name => 'Smds::JumboFixedLoan', primary_key: 'loan_num', foreign_key: 'loan_number'
  has_one  :uw_registration_validation
  has_one  :uw_submitted_not_received
  has_one  :registration_checklist, foreign_key: 'loan_num'
  has_one  :closing_checklist, foreign_key: 'loan_num'
  has_one  :funding_checklist, foreign_key: 'loan_num'
  has_many  :initial_disclosure_validations, inverse_of: :loan, primary_key: :loan_num, foreign_key: :loan_num
  has_many  :manual_fact_types, inverse_of: :loan, primary_key: :loan_num, foreign_key: :loan_num

  with_options :through => :loan_general do |assoc|
    assoc.has_one :account_info
    assoc.has_one :fha_loan
    assoc.has_one :investor_lock
    assoc.has_one :loan_feature
    assoc.has_one :lock_loan_datum
    assoc.has_one :lock_price
    assoc.has_one :mi_datum
    assoc.has_one :mortgage_term
    assoc.has_one :property
    assoc.has_one :transaction_detail
    assoc.has_one :transmittal_datum
    assoc.has_one :underwriting_datum
    assoc.has_one :arm
    assoc.has_one :risk_assessment
    assoc.has_one :va_loan
    assoc.has_one :flood_determination
    assoc.has_one :denial_letter
    assoc.has_one :additional_loan_datum

    assoc.has_many :mi_coverage_percentage
    assoc.has_many :down_payments
    assoc.has_many :loan_notes_notes
    assoc.has_many :underwriting_conditions
    assoc.has_many :calculations
    assoc.has_many :declarations
    assoc.has_many :comp_tiers_from_view
    assoc.has_many :hud_lines
    assoc.has_many :price_adjustments
    assoc.has_many :custom_fields
    assoc.has_many :assets
    assoc.has_many :purchase_credits
    assoc.has_many :compliance_alerts 
    assoc.has_many :proposed_housing_expenses
  end

  has_many :loan_officer_audits
  has_many :redwood_events
  has_many :redwood_exports, :through => :redwood_events

  delegate :last_status_date,
           :occupancy,
           :originator_name,
           :program,
           :product_code,
           :loan_purpose,
           :construction_refinance_datum,
           :purpose,
           :application_date,
           :disbursement_date,
           :cancelled_date,
           :liabilities,
           :reo_properties,
           :property_type,
           :num_of_units,
           :number_of_financed_properties,
           :is_fha?,
           :is_va?,
           :is_usda?,
           :loan_type,
           :gfe_loan_datum_property_state,
           :underwriting_datum_received_at,
           :cd_disclosure_date,
           :cd_disclosure_method_type,
           :cd_redisclosure_date,
           :cd_redisclosure_method_type,
           :document_out_date,
           :disclosed?,
           to: :loan_general, allow_nil: true
  delegate :branch_name, to: :account_info, allow_nil: true
  delegate :property_state, to: :lock_loan_datum, allow_nil: true, prefix: true
  delegate :collect_facttype, to: :manual_fact_types, allow_nil: true

  #####
  # Scopes
  #####

  scope :funded, -> {where(:is_funded => true)}
  scope :unfunded, -> {where(:is_funded => false)}
  scope :sold, -> {where(:is_sold => true)}
  scope :unsold, -> {where(:is_sold => false)}
  scope :funded_between,  lambda {|start_date, end_date| where(:funded_at => start_date..end_date) }
  scope :affiliate, -> {where(channel: Channel.retail_all_ids)}
  scope :wholesale, -> {where(channel: Channel.wholesale.identifier)}
  scope :reimbursement, -> {where(channel: Channel.reimbursement.identifier)}

  scope :for_area_manager, lambda {|area_manager| where(:area_manager => area_manager)}
  scope :for_loan_officer, lambda {|loan_officer| joins{ account_info}.where{ (account_info.broker_identifier == loan_officer) } }
  scope :for_branch_manager, lambda {|branch_id| joins{loan_general.institution}.where{loan_general.institution.institution_number == branch_id} }

  scope :jumbo, -> {where("product_code like ?", 'J%')}
  #scope :jumbo, where("product_code like ?", 'J%') #Fix this when we start doing redwood again.

   scope :uw_loans_ready_for_validation, -> { joins{ loan_general.loan_assignees.outer } \
                                        .where{
                                          (
                                            (loan_general.loan_assignees.role == 'Underwriter') &
                                            (loan_status.in ['U/W Received', 'U/W Submitted', 'U/W Final Approval/Ready for Docs'])
                                          ) | (loan_status.in ['Closing Request Received', 'Closed'])
                                          }.flatten.uniq }
                                          # Removed the underwriter selection as it is calculated in Bpm::StatsRecorder
                                          # .select("#{Loan.table_name}.*, #{LoanAssignee.table_name}.first_name + ' ' + #{LoanAssignee.table_name}.last_name AS underwriter") \
                                          # .order("#{LoanAssignee.table_name}.last_name") }
                                        

  scope :ready_for_registration_validation, -> { joins{loan_general.loan_events}.
  where{(loan_status.in ['File Received', 'U/W Submitted'])| 
    ((loan_general.loan_events.event_description == 'Add Loan Status - U/W Submitted') & 
      ((loan_general.loan_events.event_date >=  DateTime.yesterday.beginning_of_day) & (loan_general.loan_events.event_date <=  DateTime.yesterday.end_of_day)))}.uniq }

  scope :funded_for_loan_officer, lambda {|originator_id| joins{ loan_general.originator }.
                                                          where{(loan_general.originator.id == originator_id) }
                                        }

  scope :trid, -> {
    self.applied_between TRID_DATE, Date.today
  }

  scope :disclosed, -> {
    joins(:loan_general => :loan_events).where(loan_general: {loan_events: {event_description: 'DocMagic Initial Disclosure Request'}})
  }

  scope :cancelled_or_denied, -> {
    joins{loan_general.denial_letter}.
    where{"cancel_withdrawn_at is not null or denied_at is not null"}
  }

  scope :applied_between, lambda {|start_date, end_date|
    joins(:loan_general => :compliance_alerts).where(loan_general: { compliance_alerts: { application_date: (start_date.beginning_of_day..end_date.end_of_day)} })
  }

  ####
  # Aliases
  ####


  ####
  # Class Methods
  ####

  ####
  # Instance Methods
  ####

  def signature_dates_match?
    signature_dates = borrowers.map do |borrower|
      borrower.application_signed_date.try!(:strftime, '%m%d%y')
    end

    signature_dates.uniq.size == 1
  end

  def fact name
    Decisions::Facttype.new(nil, loan: self).send name.underscore
  end

  def trid_loan?
    ml = Master::Loan.find_by(loan_num: self.loan_num)
    return false unless ml
    ml.trid_loan?
  end

  def trid_application_date
    Master::Loan.find_by(loan_num: self.loan_num).try(:compliance_alerts).last.try(:application_date)
  end

  def cd_flag
    ml = Master::Loan.find_by(loan_num: self.loan_num)
    return "No" unless ml
    ml.closer_cd_flag
  end

  def mini_corr_loan?
    loan_num.starts_with?("8")
  end

  def property_appraised_value_amount
    transmittal_datum.try(:property_appraised_value_amount)
  end

  def property_estimated_value_amount
    transmittal_datum.try(:property_estimated_value_amount)
  end

  def purchase_price_amount
    transaction_detail.try(:purchase_price_amount)
  end

  def mi_and_funding_fee_total_amount
    transaction_detail.try(:mi_and_funding_fee_total_amount) || 0
  end

  #TODO clean this up and move it to loan general
  def ltv #Loan To Value http://en.wikipedia.org/wiki/Loan-to-value_ratio
    options = {}
    options[:product_code]                    = loan_general.product_code
    options[:purpose_type]                    = loan_general.loan_type
    options[:base_loan_amount]                = mortgage_term && mortgage_term.base_loan_amount
    options[:purchase_price_amount]           = purchase_price_amount
    options[:property_appraised_value_amount] = property_appraised_value_amount || property_estimated_value_amount
    options[:mi_and_funding_fee_total_amount] = mi_and_funding_fee_total_amount
    Ltv.new(options).call
  end

  def cltv #Combined Loan To Value http://en.wikipedia.org/wiki/Loan-to-value_ratio#Combined_Loan_To_Value:_.28CLTV.29_ratio
    options = {}
    options[:product_code]                    = loan_general.product_code
    options[:purpose_type]                    = loan_general.loan_type
    options[:base_loan_amount]                = mortgage_term && mortgage_term.base_loan_amount
    options[:purchase_price_amount]           = purchase_price_amount
    options[:property_appraised_value_amount] = property_appraised_value_amount || property_estimated_value_amount
    options[:subordinate_lien_amount]         = loan_general.subordinate_lien_amount
    options[:liability_amount]                = liabilities.resubordinate_mortgage_loan
    options[:mi_and_funding_fee_total_amount] = mi_and_funding_fee_total_amount
    Cltv.new(options).call
  end

  def hcltv #High Combined Loan To Value http://www.mecu.org/Help/2572.aspx
    options = {}
    options[:product_code]                    = loan_general.product_code
    options[:purpose_type]                    = loan_general.loan_type
    options[:base_loan_amount]                = mortgage_term && mortgage_term.base_loan_amount
    options[:purchase_price_amount]           = purchase_price_amount
    options[:property_appraised_value_amount] = property_appraised_value_amount || property_estimated_value_amount
    options[:subordinate_lien_amount]         = loan_general.subordinate_lien_amount
    options[:subordinate_lien_heloc_amount]   = loan_general.subordinate_lien_heloc_amount
    options[:undrawn_heloc_amount]            = loan_general.undrawn_heloc_amount
    options[:liability_amount]                = liabilities.resubordinate_mortgage_loan
    options[:mi_and_funding_fee_total_amount] = mi_and_funding_fee_total_amount
    Hcltv.new(options).call
  end

  def mi_ltv
    options = {}
    options[:product_code]                    = loan_general.product_code
    options[:purpose_type]                    = loan_general.loan_type
    options[:property_state]                  = loan_general.try(:property).try(:state)
    options[:lock_loan_property_state]        = lock_loan_datum && lock_loan_datum.property_state
    options[:gfe_loan_data_property_state]    = loan_general.gfe_loan_datum && loan_general.gfe_loan_datum.property_state
    
    options[:property_appraised_value_amount]   = property_appraised_value_amount || property_estimated_value_amount
    options[:base_loan_amount]                = mortgage_term && mortgage_term.base_loan_amount

    if (options[:product_code] != "USDA30FXD" && options[:purpose_type] == "Purchase" && (options[:property_state] == "NY" || options[:lock_loan_property_state] == "NY" || options[:gfe_loan_data_property_state] == "NY"))
      MiLtv.new(options).call
    else
      self.ltv
    end
  end
  # TODO - this is temp logic for redwood processing. This should reflect actual loan logic - Hans
  def is_jumbo?
    product_code.slice(0).upcase == 'J'
  end

  def is_locked?
    !locked_at.nil? and (lock_expiration_at.nil? or lock_expiration_at > Date.today)
  end

  def rate_lock_status
    case
      when is_locked? then 'Locked'
      when locked_at.nil? then 'Not Locked'
      when lock_expiration_at < Date.tomorrow then 'Expired'
      else 'Unknown'
    end
  end

  # Message should alert the user that they have found an employee loan and can not access.
  def can_see_loan?(current_user)
    return (current_user.is_underwriter_with_employee_loan_permission? || current_user.is_registration_with_employee_loan_permission? || current_user.is_preclosing_with_employee_loan_permission? || current_user.is_closing_with_employee_loan_permission? || current_user.is_suspense_with_employee_loan_permission? || current_user.roles.include?('funder_employee_loans')) if loan_general.try(:additional_loan_datum).try(:employee_loan_indicator)
    current_user.is_underwriter? or current_user.is_underwriter_with_employee_loan_permission? or current_user.is_closing? or current_user.is_closing_with_employee_loan_permission? or current_user.is_registration? or current_user.is_registration_with_employee_loan_permission? or current_user.is_bpm? or current_user.is_admin? or current_user.is_preclosing? or current_user.is_preclosing_with_employee_loan_permission? or current_user.is_suspense? or current_user.is_suspense_with_employee_loan_permission? or current_user.roles.include?('funder') or current_user.roles.include?('funder_employee_loans')
  end

  # TODO - Determine if this is the correct date math
  # to determine a lock date - Hans/Steve
  def lock_term
    days_between(expiration_date - lock_date) rescue nil
  end

  def is_construction_only?
    loan_purpose.to_s.downcase == 'constructiononly' rescue false
  end

  def is_construction_to_permanent?
    loan_purpose.to_s.downcase == 'constructiontopermanent' rescue false
  end

  def is_wholesale?
    channel == Channel.wholesale.identifier
  end

  def loan_purpose_description
    PURPOSE_OF_REFINANCE_DICT[construction_refinance_datum.gse_refinance_purpose_type] if construction_refinance_datum
  end
  # Note that this method doesn't show actual total income, since some of our records seem to be nil.
  def borrowers_income_total
    borrowers.inject(0.0){|sum, b| sum += b.income_total }
  end
  alias_method :borrower_income_total, :borrowers_income_total
  alias_method :borrowers_income,      :borrowers_income_total
  alias_method :borrower_income,       :borrowers_income_total

  def primary_borrower
    borrowers.primary
  end

  def escrow_waiver?
    # TODO
    true
  end

  def originator_replaced?
    # !loan_officer_audits.empty? and loan_officer_audits.count > 1
    loan_general.loan_events.map{|e| e if e.event_description.starts_with?('Loan Transfer Completed')}.compact.count > 0
  end

  def first_time_homebuyer?
    return true if declarations && declarations.map(&:homeowner_past_three_years_type).include?('No')
    return true if lock_loan_datum && lock_loan_datum.first_time_homebuyer
    false
  end

  def borrower_full_name
    "#{borrower_first_name} #{borrower_last_name}"
  end

  def latest_underwriter
    if loan_general.loan_assignees.underwriter.blank?
      last_to_access = read_last_note('UnderwriterAccess')
      return "No access record"  unless last_to_access.present?
      "#{last_to_access.body} at #{last_to_access.created_at.in_time_zone('Eastern Time (US & Canada)').strftime('%m/%d/%Y %I:%S %p')}"
    else
      underwriter = loan_general.loan_assignees.underwriter.first
      "UNDERWRITER: #{underwriter.first_name} #{underwriter.last_name}"
    end
  end

  def lowest_fico_score
    borrowers.collect(&:credit_score).min || 0
  end

  def subordinate_financing?
    Array(liabilities).each do |liability|
      return "Yes" if liability.subordinate? == "Yes"
    end

    "No"
  end

  def gse_property_type
    return loan_general.lock_loan_datum.gse_property_type if loan_general.lock_loan_datum and loan_general.lock_loan_datum.gse_property_type.present?
    return loan_general.loan_feature.gse_property_type if loan_general.loan_feature and loan_general.loan_feature.gse_property_type.present?
    nil
  end

  def gfe_property_state
    property.try(:state).presence ||
    lock_loan_datum_property_state.presence ||
    gfe_loan_datum_property_state
  end

  def init_disc_property_state
    gfe_loan_datum_property_state ||
    property.try(:state).presence ||
    lock_loan_datum_property_state.presence
  end

  def init_disc_product_code
    underwriting_datum.try(:product_code).presence ||
    loan_feature.try(:product_name).presence ||
    lock_price.try(:product_code).presence
  end

  def loan_product_name
    prod = ProductDatum.where(product_code: self.product_code).first
    prod ? prod.product_name : nil
  end

  def loan_guideline_doc
    doc = ProductGuideline.loan_guideline_doc(product_code, channel, loan_general.underwriting_datum.submitted_at) rescue nil
    doc || ProductGuideline.loan_guideline_doc(product_code, channel, Date.tomorrow)
  end

  def pe_credit_scores
    scores = borrowers.collect(&:credit_score).compact
    scores = loan_general.try(:underwriting_datum).try(:borrower_credit_score) if scores.empty?
    scores
  end

  def underwriter_submission_received_at
    Chronic.parse(custom_fields.where(attribute_unique_name: 'UWSubmissionRcvd', form_unique_name: 'Submit File to UW').first.attribute_value) rescue nil
  end

  def total_loan_amount_first_mortgage
    '%.2f' % mortgage_term.base_loan_amount rescue '0.00'
  end

  def total_gift_amount
    try(:assets).where{asset_type.in(["GiftsTotal", "GiftsNotDeposited"])}.map{|c| c.cash_amount.to_f}.sum
  end

  def total_verified_borrower_funds
    try(:assets).where{asset_type.not_in(["GiftsTotal", "GiftsNotDeposited"])}.map{|c| c.cash_amount.to_f}.sum + 
    try(:purchase_credits).where{credit_type.in(["EarnestMoney"])}.map{|c| c.amount.to_f}.sum
  end

  def earnest_money_amount
    try(:purchase_credits).where{credit_type.in(["EarnestMoney"])}.map{|c| c.amount.to_f}.sum
  end

  def total_verified_assets
    try(:assets).all.map{|c| c.cash_amount.to_f}.sum + 
    try(:purchase_credits).where{credit_type.in(["EarnestMoney"])}.map{|c| c.amount.to_f}.sum
  end

  def purpose_of_refinance
    construction_refinance_datum && construction_refinance_datum.gse_refinance_purpose_type
  end

  def total_funds_required
    (purchase_price_amount.to_f - loan_general.try(:lock_loan_datum).try(:total_loan_amt).to_f) +
      transaction_detail.try(:prepaid_items_estimated_amount).to_f + transaction_detail.try(:estimated_closing_costs_amount).to_f
  end

  def aus_type
    return nil unless risk_assessment.try(:aus_type)
    risk_assessment.try(:aus_type) == 'Manual' ? 'Manual Underwriting' : 'AUS'
  end

  def underwriting_status
    status = underwriting_datum.try(:status)
    return '' unless status
    return "Pre-Approval" if status == "PRE-APPROVED"
    status.titleize
  end

  def hpml_status
    master_loan = Master::Loan.where(loan_num: self.loan_num).last
    status = HpmlResult.for(master_loan) if master_loan.present?
    status ? 'HPML' : 'Not HPML'
  end

  def mshda_note_indicator_check
    loan_notes_notes.select {|lc| lc.content.include?("Signed MSHDA seller affidavit received") &&  lc.content.include?("signed prior to closing")}.map{|lc|}.flatten.empty? ? 'No' : 'Yes'
  end

  def check_underwriting_condition_expiration_date expiration_type
    date = underwriting_conditions.select { |uw| uw.condition.starts_with?("#{expiration_type}") && uw.status == "Pending"}.map{|uw| uw.condition.scan(/\d{1,2}\/\d{1,2}\/\d{2,4}/)}.flatten
    if date.empty?
      date = underwriting_conditions.select { |uw| uw.condition.starts_with?("#{expiration_type}")}.map{|uw| uw.condition.scan(/\d{1,2}\/\d{1,2}\/\d{2,4}/)}.flatten
    end
    return nil if date.empty?
    date = Date.parse(date.last) rescue nil
    return nil if date.nil?
    date.strftime(I18n.t('date.formats.default'))  
  end

  def calculate_tandl_underwriting
    proposed_housing_expenses.select {|phe| phe.housing_expense_type.in?(["HazardInsurance", "RealEstateTax", "MI", "HomeownersAssociationDuesAndCondominiumFees", "OtherHousingExpense"]) }.map{|res| res.payment_amount.to_f}.sum.round(2)
  end

  def calculate_tandl_closing
    response = hud_lines.select {|hl| (hl.sys_fee_name.in?(["Homeowner's insurance", "Mortgage insurance", "City property taxes", "County property taxes", "Flood insurance"]) || (hl.user_def_fee_name.include?("Tax") if hl.user_def_fee_name) || (hl.user_def_fee_name.include?("Insurance") if hl.user_def_fee_name)) && hl.hud_type == 'HUD' }.map{|r| r.monthly_amt.to_f}
    return nil if response.empty?
    response.sum.round(2)
  end

  def mortgage_insurance_amount_1003
    proposed_housing_expenses.select {|phe| phe.housing_expense_type == 'MI'}.map{|res| res.payment_amount.to_f}.sum.round(2)
  end

  def rate_lock_request_escrow_waiver
    indicator = try(:lock_loan_datum).escrow_waiver_indicator
    return 'Yes' if indicator == true
    return 'No' if indicator == false
    return nil
  end
  
  def calculate_sum_of_liquid_assets
    response = try(:assets).select {|ast| ast.asset_type.in?([ "CertificateOfDepositTimeDeposit", "CheckingAccount", "GiftsTotal", "GiftsNotDeposited", "MoneyMarketFund", "OtherLiquidAssets", "SavingsAccount"]) && ast.borrower_id.in?(["BRW1", "BRW2", "BRW3", "BRW4"])}.map{|res| res.cash_amount.to_f}
    return nil if response.empty?
    response.sum.round(2)
  end

  def calculate_closing_plus_rescission_date
    if loan_feature.requested_closing_date 
      BusinessTime::Config.work_week = [:mon, :tue, :wed, :thu, :fri, :sat]
      closing_date = loan_feature.requested_closing_date.to_date
       rescission_date = closing_date.holiday?(:us) ? 3.business_days.after(closing_date) : 4.business_days.after(closing_date) 
      BusinessTime::Config.work_week = [:mon, :tue, :wed, :thu, :fri] 
      if rescission_date.to_date.holiday?(:us) || rescission_date.to_date.saturday?
        rescission_date = 0.business_day.after(rescission_date)
      end
      rescission_date.strftime(I18n.t('date.formats.default')) 
    end
  end

  def fact_types
    {
      "InitialRateLockDate"          => lock_loan_datum && lock_loan_datum.initial_lock_performed_date && lock_loan_datum.initial_lock_performed_date.strftime(I18n.t('date.formats.default')),
      "SubmitToUnderwritingDate"     => underwriter_submission_received_at && underwriter_submission_received_at.strftime(I18n.t('date.formats.default')),
      "TotalLoanAmountFirstMortgage" => total_loan_amount_first_mortgage,
      "PropertyType"                 => FactTranslator.property_type(gse_property_type),
      "PropertyState"                => gfe_property_state,
      "LoanProductName"              => FactTranslator.loan_product_name(loan_general.product_code),
      "LowestFICOScore"              => LowestFicoScore.new(pe_credit_scores).call,
      "PurposeOfLoan"                => FactTranslator.purpose_of_loan(loan_type),
      "PurposeOfRefinance"           => FactTranslator.purpose_of_refinance(purpose_of_refinance),
      "OccupancyType"                => FactTranslator.occupancy_type(occupancy),
      "HCLTV"                        => hcltv,
      "SubordinateFinancing"         => subordinate_financing?,
      "NumberOfUnits"                => FactTranslator.number_of_units(num_of_units),
      "CLTV"                         => cltv,
      "ChannelName"                  => FactTranslator.channel_name(channel),
      "LTV"                          => ltv,
      "PropertyPurchasePrice"        => purchase_price_amount,
      "AUSRiskAssessment"            => transmittal_datum && transmittal_datum.au_engine_type,
      "InitialRateSheetDate"         => lock_price && lock_price.locked_at.strftime(I18n.t('date.formats.default')),
      "BaseLoanAmount1003"           => mortgage_term && mortgage_term.base_loan_amount.to_s,
      "TotalFundsRequired"           => total_funds_required,
      "FirstTimeHomebuyer"           => first_time_homebuyer? ? 'Yes' : 'No',
      "CountyLoanLimit"              => county_loan_limit,
      "TotalGiftAmount"              => total_gift_amount,
      "NumberOfFinancedProperties"   => number_of_financed_properties,
      "LPOverrideReservesAmount"     => transaction_detail.try(:fre_reserves_amount),
      "DTI"                          => try(:debt_to_income_ratio),
      "InterestRate1003"             => mortgage_term.try(:requested_interest_rate_percent),
      "ARMQualifyingRate"            => try(:arm).try(:qualifying_rate_percent),
      "FieldworkObtained"            => try(:transmittal_datum).try(:fieldwork_obtained),
      "OfferingIdentifier"           => loan_feature.try(:fre_offering_identifier),
      "PUDIndicator"                 => property.try(:planned_unit_development_indicator) ? 'Yes' : 'No',
      "AUSRecommendation"            => aus_recommendation, #risk_assessment.try(:aus_recommendation),
      "RiskAssessment"               => aus_type,
      "UnderwritingStatus"           => underwriting_status,
      "HPMLStatus"                   => hpml_status,
      "TotalVerifiedBorrowerFunds"   => total_verified_borrower_funds,
      "TotalVerifiedAssets"          => total_verified_assets,
    }
  end

  def save_last_underwriter_access(user_name)
    last_to_access = read_last_note('UnderwriterAccess')  
    if last_to_access.blank?
      msg = "Last viewed by #{user_name}"
      write_note msg, 'UnderwriterAccess'
      "#{msg} at #{Time.now.strftime('%m/%d/%Y %I:%S %p')}"
    end
  end

  def self.ready_for_registration_validation_multi_step

    loans = Loan.
      where{(loan_status.in ['File Received', 'U/W Submitted'])}

    evs = LoanEvent.
        where{((event_description == 'Add Loan Status - U/W Submitted') & 
          ((event_date >=  DateTime.yesterday.beginning_of_day) & (event_date <=  DateTime.yesterday.end_of_day)))}.uniq

    ids = evs.map(&:loan_general_id)

    lgs = LoanGeneral.where('loan_general_id in (?)', ids).map(&:lender_registration_id)

    loans_evs = Loan.where('loan_num in (?)', lgs)

    return (loans + loans_evs).uniq

  end

  def denied_cancelled_withdrawn?
    !denial_letter.nil? && (!denial_letter.cancel_withdrawn_at.nil? || !denial_letter.denied_at.nil?)
  end

  def primary_borrower_mailing_address
    loan_general.mailing_addresses.brw1.first.try(:mailing_address)
  end

  def title_company_name
    loan_general.closing_agents.where(agent_type: 'TitleCompany').first.try(:name).to_s
  end

  def is_texas_50A6
    if is_wholesale?
      form_name = "Wholesale Initial Disclosure Request"
      att_name = "Texas Loans Only -"
    else
      form_name = "Retail Initial Disclosure Request"
      att_name = "TexasLoansOnly"
    end

    value = custom_fields.where(form_unique_name: form_name, attribute_unique_name: att_name).last.try(:attribute_value)
    case value
    when "Y"
      'Yes'
    when "N"
      'No'
    when 'NA'
      'NA'
    else
      'No Entry'
    end
  end

  def comp_tier
    return unless is_wholesale?
    if lock_price.is_loan_locked?
      effective_date = lock_price.locked_at.to_date
    else
      effective_date = Date.today
    end
    c_tiers = loan_general.try!(:institution).try!(:comp_tiers)
    return nil if c_tiers.nil?
    c_tiers.where("effective_at <= ?", effective_date).where("effective_until IS NULL OR effective_until >= ?", effective_date).try!(:last)
  end

private

  def record_validation_error(exception)
    errors[:validation_error] << '==== >>>> ATTENTION: Due to internal issues some validations were NOT performed.'
    Airbrake.notify(exception)
    message = Notifier.underwriter_validation_error(self, exception, type = '')
    Email::Postman.call message
  end

  def county_loan_limit
    begin
      # catches service not working errors
      require 'net/http'

      limit_check_type  =   product_type

      uri               =   URI.parse("#{SERVICES_PATH}/county_loan/get_limit_amount")

      date_of_loan      =   [
                              loan_general.try(:gfe_detail).try(:application_received_date),
                              loan_general.try(:lock_loan_datum).try(:performed_date),
                              submit_to_underwriting_date
                            ].compact.max

      paramtrs          =  {
                          limit_check_type: limit_check_type,
                          state: property_state,
                          county: property_county,
                          limit_transaction_date: date_of_loan.strftime('%Y-%m-%d'),
                          number_of_units: num_of_units,
                          base_loan_amount_first_mortgage: loan_general.try(:lock_loan_datum).try(:total_loan_amt)
                        }

      response          = Net::HTTP.post_form(uri, paramtrs)

      return response.body
    rescue
      nil
    end
  end

  def product_type
    return 'CountyLoan::LimitFha' if loan_general.product_code.start_with?('FHA')
    return 'CountyLoan::LimitVa'  if loan_general.product_code.start_with?('VA')
    'CountyLoan::LimitFnma'
  end

  def aus_recommendation
    return nil unless transmittal_datum
    
    case transmittal_datum.last_submitted_au_recommendation
      when 'Eligible/Accept/Accept'
        return 'Accept Eligible'
      when 'Ineligible/Accept/Accept'
        return 'Accept Ineligible' 
      when 'Approve/Eligible'
        return 'Approve Eligible'
      when 'Approve/Ineligible'
        return 'Approve Ineligible'
      when 'Ineligible/Caution/Caution'
        return 'Caution Ineligible'
      when 'EA-I/Eligible'
        return 'EAI Eligible'
      when 'EA-I/Ineligible'
        return 'EAI Ineligible'
      when 'EA-II/Eligible'
        return 'EAII Eligible'
      when 'EA-II/Ineligible'
        return 'EAII Ineligible'
      when 'EA-III/Eligible'
        return 'EAIII Eligible'
      when 'EA-III/Ineligible'
        return 'EAIII Ineligible'
      when 'N/A'
        return 'Error'
      when 'Out of Scope'
        return 'Out of Scope'
      when 'Refer/Eligible'
        return 'Refer Eligible'
      when 'Refer/Ineligible'
        return 'Refer Ineligible'
      when 'N/A/Refer/Refer'
        return 'Refer Refer'
      when 'Refer W Caution/IV'
        return 'Refer With Caution IV'
      when 'Submit/Error'
        return 'Error'
      when 'N/A/Accept/Accept'
        return 'NA Accept Accept'
      when 'Eligible/Caution/Caution'
        return 'Caution Eligible'
      when 'Refer with Caution'
        return 'Refer with Caution'
    end
  end

end
