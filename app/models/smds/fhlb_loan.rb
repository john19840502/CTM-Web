class Smds::FhlbLoan < DatabaseDatamartReadonly

  def self.primary_key
    'SellerLoanIdentifier'
  end

  belongs_to :master_loan, class_name: 'Master::Loan', foreign_key: 'SellerLoanIdentifier', primary_key: 'loan_num'
  has_many :liabilities, through: :master_loan
  has_many :master_borrowers, through: :master_loan, source: :borrowers
  belongs_to :loan_general, foreign_key: 'SellerLoanIdentifier', primary_key: :loan_id
  has_one :transaction_detail, through: :loan_general
  delegate :number_of_financed_properties, to: :loan_general, allow_nil: true
  belongs_to :compass_loan_detail, :class_name => 'Smds::CompassLoanDetail', foreign_key: 'SellerLoanIdentifier', primary_key: :loan_number
  delegate :AssumabilityIndicator, to: :compass_loan_detail, allow_nil: true

  def self.sqlserver_create_view
    Smds::FnmaLoan::SELECT_CLAUSE_SQL
  end

  def pool_id
    "FH#{self.InvestorContractIdentifier}"
  end

  def delivery_type
    "FHLB"
  end

  def InvestorRemittanceType
    "ActualInterestActualPrincipal"
  end

  def InvestorRemittanceDay
    '18'
  end

  def InvestorCommitmentIdentifier
    self.compass_loan_detail.investor_commitment_number[2..-1]
  end

  def LoanAcquisitionScheduledUPBAmount
    return '' if (self.CalcSoldScheduledBal.nil? || self.CalcSoldScheduledBal < 0)
    self.CalcSoldScheduledBal.round(2)
  end

  def LoanDefaultLossPartyType
    'Investor'
  end

  def REOMarketingPartyType
    'Investor'
  end

  include Smds::DeliveryModelMethods
  include Smds::DataCleanupMethods
  include Smds::UlddMethods

end
