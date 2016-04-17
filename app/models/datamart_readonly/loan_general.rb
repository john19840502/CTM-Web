class LoanGeneral < DatabaseDatamartReadonly
  has_one :account_info
  has_one :additional_loan_datum
  has_one :arm
  has_one :cond_pending_review
  has_one :construction_refinance_datum
  has_one :denial_letter
  has_one :detail
  has_one :fha_loan
  has_one :flood_determination
  has_one :funding_data
  has_one :gfe_additional_datum
  has_one :gfe_detail
  has_one :gfe_loan_datum
  has_one :institution, through: :account_info
  has_one :interviewer
  has_one :investor_lock
  has_one :loan_detail
  has_one :loan_feature
  has_one :loan_purpose
  has_one :lock_loan_datum
  has_one :lock_price
  has_one :mi_datum
  has_one :mortgage_term
  has_one :originator, through: :account_info
  has_one :property
  has_one :rate_adjustment
  has_one :requester
  has_one :risk_assessment
  has_one :transaction_detail
  has_one :transmittal_datum
  has_one :underwriting_datum
  has_one :va_loan
  has_one :wire_tracking

  has_many :assets
  has_many :borrower_addresses
  has_many :mailing_addresses
  has_many :borrowers
  has_many :calculations
  has_many :closing_agents
  has_many :comp_tiers_from_view, class_name: "CompTierFromView"
  has_many :compliance_alerts
  has_many :current_incomes
  has_many :custom_fields
  has_many :declarations
  has_many :down_payments
  has_many :government_monitorings
  has_many :hmda_races
  has_many :hud_lines
  has_many :liabilities
  has_many :loan_assignees
  has_many :loan_events
  has_many :loan_notes_notes
  has_many :paid_by_fee
  has_many :present_housing_expenses
  has_many :price_adjustments
  has_many :proposed_housing_expenses
  has_many :purchase_credits
  has_many :real_borrowers
  has_many :reo_properties
  has_many :shippings
  has_many :underwriting_conditions
  has_many :mi_renewal_premia, class_name: 'Master::MiRenewalPremium', primary_key: :id, foreign_key: :loan_id
  has_many :residences

  belongs_to :loan

  delegate :channel, to: :account_info, prefix: false, allow_nil: true
  delegate :state, to: :property, prefix: true, allow_nil: true
  delegate :product_name, to: :loan_feature, prefix: true, allow_nil: true
  delegate :is_refi?, :is_purchase?, :loan_type, to: :loan_purpose, prefix: false, allow_nil: true
  delegate :loan_type, to: :loan_purpose, prefix: false, allow_nil: true
  delegate :subordinate_lien_amount, to: :transaction_detail, prefix: false, allow_nil: true
  delegate :subordinate_lien_heloc_amount, to: :transaction_detail, prefix: false, allow_nil: true
  delegate :undrawn_heloc_amount, to: :transaction_detail, prefix: false, allow_nil: true
  delegate :application_date, to: :gfe_detail, allow_nil: true
  delegate :disbursement_date, :cancelled_date, to: :loan_detail
  delegate :property_type, to: :property, allow_nil: true
  delegate :num_of_units, to: :property, allow_nil: true
  delegate :received_at, to: :underwriting_datum, prefix: true, allow_nil: true
  delegate :property_state, to: :gfe_loan_datum, prefix: true, allow_nil: true
  delegate :cd_disclosure_date,
           :cd_disclosure_method_type,
           :cd_redisclosure_date,
           :cd_redisclosure_method_type,
           :document_out_date,
           to: :loan_detail, allow_nil: true
  delegate :loan_forceclosure_indicator, to: :declarations, allow_nil: true

  alias_method :branch, :institution

  CREATE_VIEW_SQL = <<-eos
      SELECT     loanGeneral_Id AS id,
                 loanGeneral_Id AS loan_general_id,
                 LenderDTDVersionID AS lender_dtd_version_id,
                 LenderRegistrationIdentifier AS lender_registration_id,
                 LenderRegistrationIdentifier AS loan_id,
                 loanStatus AS loan_status,
                 RequestDateTime AS requested_at,
                 ReceiveDateTime AS received_at,
                 User_Id AS db_user_id
      FROM       LENDER_LOAN_SERVICE.dbo.[LOAN_GENERAL]
      WHERE      loanStatus = 20
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def application_date
    compliance_alerts.last.try(:application_date)
  end

  def borrower_last_name
    self.real_borrowers.first.try(:borrower_last_name)
  end

  def disclosed?
    loan_events.map{|event| event.event_description}.include? 'DocMagic Initial Disclosure Request'
  end

  def occupancy
    loan_purpose.property_usage_type if loan_purpose
  end

  def lo_first_name
    account_info.broker_first_name
  end

  def lo_last_name
    account_info.broker_last_name
  end

  def originator_name
    originator ? originator.name : [lo_first_name.presence, lo_last_name.presence].compact.join(' ')
  end

  def product_code
    if underwriting_datum && underwriting_datum.product_code.present?
      underwriting_datum.product_code
    elsif loan_feature && loan_feature.product_name.present?
      loan_feature.product_name
    elsif lock_price && lock_price.product_code.present?
      lock_price.product_code
    else 
      gfe_loan_datum.try(:loan_program)
    end
  end

  def purpose
    case
    when is_purchase?  then 'PURCHASE'
    when is_refi_plus? then 'REFIPLUS'
    when is_refi?      then 'REFINANCE'
    else ''
    end
  end

  def is_fha?
    product_code.to_s.upcase.starts_with? 'FHA'
  end

  def is_va?
    product_code.to_s.upcase.starts_with? 'VA'
  end

  def is_usda?
    product_code.to_s.upcase.starts_with? 'USDA'
  end

  def program
    # I don't love this logic... - Hans
    # TODO - make this not suck
    value = ''
    value = 'VA' if is_va?
    value = 'FHA' if is_fha?
    value = 'USDA' if is_usda?
    value
  end

  def is_refi_plus?
    product_code.last(2).upcase == 'RP' rescue false
  end

  def last_status_date
    loan_events.maximum(:event_date)
  end

  def mortgage_payment_to_income_ratio_percent
    calculations.where(:name => 'MortgagePaymentToIncomeRatioPercent').first.value rescue nil
  end

  # def total_obligations_income_ratio
  #   calculations.where(:name => 'TotalObligationsIncomeRatio').first.value rescue nil
  # end

  def borrower_paid_outside_closing
    purchase_credits.where(:name => 'BorrowerPaidOutsideClosing').first.value rescue nil
  end

  def purchase_credit_amount
    purchase_credits.map(&:amount).sum rescue nil
  end

  def escrow_from_lock
    return nil unless lock_loan_datum
    lock_loan_datum.escrow_waiver_indicator ? 'Yes' : 'No'
  end

  def escrow_from_1003
    return nil unless loan_feature
    loan_feature.escrow_waiver_indicator ? 'Yes' : 'No'
  end

  def total_balance_secondary_financing
    # * SubjectLoanResubordinationIndicator = Y, _UnpaidBalanceAmount + SubordinateLienAmount
    if liabilities.any? and liabilities.map {|l| true if  l.subject_loan_resubordination_indicator }.compact.any?
      return liabilities.map {|l| l.unpaid_balance_amount if  l.subject_loan_resubordination_indicator }.compact.sum + (transaction_detail.subordinate_lien_amount || 0)
    end
    0
  end

  def max_amount_secondary_financing
    # * SubjectLoanResubordinationIndicator = Y, _UnpaidBalanceAmount + SubordinateLienAmount + UndrawnHelocAmount
    if liabilities.any? and liabilities.map {|l| true if  l.subject_loan_resubordination_indicator }.compact.any?
      return total_balance_secondary_financing + (transaction_detail.undrawn_heloc_amount || 0)
    end
    0
  end

  def proposed_housing_expenses_has_amount_for_type?(exp_type)
    if proposed_housing_expenses and proposed_housing_expenses.length > 0
      proposed_housing_expenses.map {|ph| ph.payment_amount if ph.housing_expense_type.eql?(exp_type)}.compact.map {|v| v if v > 0}.compact.length > 0
    end
  end

  def current_incomes_has_amount_for_type?(exp_type)
    if current_incomes and current_incomes.length > 0
      current_incomes.map {|ph| ph.monthly_total_amount if ph.income_type.eql?(exp_type)}.compact.map {|v| v if v != 0}.compact.length > 0
    end
  end

  def present_housing_expenses_has_amount_for_type?(exp_type)
    if present_housing_expenses and present_housing_expenses.length > 0
      present_housing_expenses.map {|ph| ph.payment_amount if ph.housing_expense_type.eql?(exp_type)}.compact.map {|v| v if v > 0}.compact.length > 0
    end
  end

  def reo_property_r1
    reo_properties.any? ? reo_properties.map{|r| r if r.reo_id.eql?('R1')}.compact[0] : nil
  end

  def reo_property_current_residence
    reo_properties.any? ? reo_properties.map{|r| r if r.current_residence_indicator}.compact[0] : nil
  end

  def is_preapproval?
    custom_fields.is_preapproval?
  end

  def intent_to_proceed_date
    custom_fields.intent_to_proceed_date_string.try(:to_datetime)
  end

  def application_was_received?
    try(:additional_loan_datum).try(:application_creation_date_time_in_avista).present?
  end

  delegate :initial_lock_performed_date, to: :lock_loan_datum, allow_nil: true

  def locked?
    !initial_lock_performed_date.nil?
  end

  delegate :in_uw_station?, :not_in_uw_station?, to: :custom_fields


  def number_of_financed_properties
    default_value = 1
    if application_was_received? && !locked? && in_uw_station? && reo_properties.none?
      default_value
    elsif !application_was_received? && locked? && not_in_uw_station? && reo_proprties.none?
      default_value
    elsif application_was_received? && locked? && not_in_uw_station? && reo_proprties.none?
      default_value
    elsif application_was_received? && locked? && in_uw_station? && reo_properties.none?
      default_value
    else
      1 + liabilities.financed_properties
    end
  end
end
