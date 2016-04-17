class Smds::Pool < DatabaseRailway
  self.table_name_prefix += 'smds_'

  scope :fnma, ->{ where(prefix: 'ME') }
  scope :fhlmc, ->{ where(prefix: 'MC') }
  scope :fhlb, ->{ where(prefix: 'FH') }

  has_many :compass_loan_details, :class_name => 'Smds::CompassLoanDetail', foreign_key: :investor_commitment_number, primary_key: :investor_commitment_number

  validates :investor_commitment_number, uniqueness: true
  validates :pool_suffix_identifier, uniqueness: { scope: :investor_commitment_number }

  default_values pool_fixed_servicing_fee_percent: 0.25,
                 pool_scheduled_remittance_payment_day: '18',
                 pool_accrual_rate_structure_type: 'StatedStructure'

  COLUMN_OPTIONS = {
      pool_accrual_rate_structure_type: [%w(StatedStructure Stated), %w(WeightedAverageStructure Weighted)],
      pool_structure_type: [%w(InvestorDefinedMultipleLender Fannie\ Major),
                            %w(LenderInitiatedMultipleLender Lender\ Initiated\ Multiple),
                            %w(SingleLender Single)]
  }

  INPUT_TYPE = {
      pool_accrual_rate_structure_type: :select,
      pool_interest_only_indicator: :checkbox,
      pool_issue_date: :date,
      pool_structure_type: :select,
      security_trade_book_entry_date: :date,
      certification_date: :date,
      assumability_indicator: :checkbox
  }

  DISPLAY_WITH = {
      total_upb: :number_to_currency,
      settlement_date: :l,
      certification_date: :l
  }

  coerce_sqlserver_date :pool_issue_date
  coerce_sqlserver_date :security_trade_book_entry_date
  coerce_sqlserver_date :certification_date
  coerce_sqlserver_date :settlement_date

  ##FILTER BY DATE##
  require 'filter_by_date_model_methods'
  extend FilterByDateModelMethods

  def self.filter_by_date_method
    :settlement_date
  end
  ##FILTER BY DATE##

  def self.find_by_pool_number(pool_number)
    find_by_investor_commitment_number(pool_number)
  end

  def self.editable_columns
    blacklist = %w(id created_at updated_at investor_commitment_number number_of_loans total_upb exported_by exported_at)

    attribute_names - blacklist
  end

  def self.editable?(column_name)
    editable_columns.include? column_name
  end

  def self.options_for_column(column_name)
    COLUMN_OPTIONS[column_name.to_sym]
  end

  def self.input_type(column_name)
    INPUT_TYPE[column_name.to_sym] || :input
  end

  def self.display_with(column_name)
    DISPLAY_WITH[column_name.to_sym]
  end

  def fnma_loans
    Smds::FnmaLoan.find(compass_loan_details.map(&:loan_number))
  end

  def gnma_loans
    compass_loan_details.map(&:fnma_loan)
  end

  def fhlmc_loans
    Smds::FhlmcLoan.includes(:hud_lines).find(compass_loan_details.map(&:loan_number))
  end

  def fhlb_loans
    Smds::FhlbLoan.find(compass_loan_details.map(&:loan_number))
  end

  def loans ctrlr
    return fnma_loans if ctrlr.is_a? Delivery::FnmaLoansController
    return fnma_loans if ctrlr.is_a? Delivery::FnmaPoolsV2Controller
    return gnma_loans if ctrlr.is_a? Delivery::GnmaLoansController
    return fhlmc_loans if ctrlr.is_a? Delivery::FhlmcPoolsController
    return fhlmc_loans if ctrlr.is_a? Delivery::FhlmcCashController
    return fhlb_loans if ctrlr.is_a? Delivery::FhlbPoolsController
    raise "unexpected loan type"
  end

  def number_of_loans
    compass_loan_details.all.count
  end

  def total_upb
    compass_loan_details.inject(0) { |sum,loan| sum += loan.upb }
  end

  def party_role_identifier
    '20000398668'
  end

  def pool_assumability_indicator
    self.compass_loan_details.first.try!(:AssumabilityIndicator)
  end

  def pool_balloon_indicator
    false
  end

  def pool_identifier
    #Identifier numbers are 6 digits long, between the prefix and any suffix.
    self.investor_commitment_number[2..7]
  end

  def pool_mortgage_type
    'Conventional'
  end

  def pool_ownership_percent
    '100'
  end

  def originator(user)
    self.exported_by = user.display_name
    self.exported_at = Time.now
    self.save
  end

  def is_fhlb?
    prefix == "FH"
  end

  def first_loan
    case prefix
    when 'MC' then fhlmc_loans.first
    when 'ME' then fnma_loans.first
    when 'FH' then fhlb_loans.first
    else gnma_loans.first
    end
  end

  def pool_amortization_type
    first_loan.try(:amortization_type)
  end
end
