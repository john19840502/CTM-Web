class Smds::CashCommitment < DatabaseRailway
  self.table_name_prefix += 'smds_'

  validates :investor_commitment_number, uniqueness: true

  coerce_sqlserver_date :certified_on
  coerce_sqlserver_date :settlement_date

  has_many :compass_loan_details, :class_name => 'Smds::CompassLoanDetail', foreign_key: :investor_commitment_number, primary_key: :investor_commitment_number

  DISPLAY_WITH = {
      total_upb: :number_to_currency,
      settlement_date: :l,
      certified_on: :l
  }

  def self.editable?(column_name)
    %w(certified_on).include?(column_name)
  end

  def self.input_type(column_name)
    :date
  end

  def self.options_for_column(column_name)
    []
  end

  def self.display_with(column_name)
    DISPLAY_WITH[column_name.to_sym]
  end

  ##FILTER BY DATE##
  require 'filter_by_date_model_methods'
  extend FilterByDateModelMethods

  def self.filter_by_date_method
    :settlement_date
  end
  ##FILTER BY DATE##

  def self.create_all
    investor_numbers = Smds::CompassLoanDetail.cash_numbers
    pool_numbers = self.pluck(:investor_commitment_number)
    pools_to_create = investor_numbers - pool_numbers
    pools_to_create.each do |pool|
      date = Smds::CompassLoanDetail.where(investor_commitment_number: pool).pluck(:settlement_date).first
      cc = self.new
      cc.investor_commitment_number = pool
      cc.settlement_date = date
      cc.save!
    end
  end

  def self.fhlmc_only
    where{(investor_commitment_number =~ 'FD%')}
  end

  def self.fnma_only
    where{(investor_commitment_number =~ 'FN%')}
  end

  def is_fhlb?
    return true if investor_commitment_number.nil? # It is not clear on what will be the value in case of FHLB yet
    investor_commitment_number.start_with?('FN') || investor_commitment_number.start_with?('FD') ? false : true
  end

  def pool_identifier
    #Identifier numbers are 6 digits long, between the prefix and any suffix.
    self.investor_commitment_number[2..7]
  end

  def originator(user)
    self.exported_by = user.display_name
    self.exported_at = Time.now
    self.save
  end

  def fnma_loans
    Smds::FnmaLoan.find(compass_loan_details.map(&:loan_number))
  end

  def fhlmc_loans
    Smds::FhlmcLoan.includes(:hud_lines).find(compass_loan_details.map(&:loan_number))
  end

  def loans ctrlr
    return fnma_loans if ctrlr.is_a? Delivery::FnmaCashController
    return fnma_loans if ctrlr.is_a? Delivery::FnmaLoansController
    return gnma_loans if ctrlr.is_a? Delivery::GnmaLoansController
    return fhlmc_loans if ctrlr.is_a? Delivery::FhlmcPoolsController
    return fhlmc_loans if ctrlr.is_a? Delivery::FhlmcCashController
    raise "unexpected loan type"
  end

  def number_of_loans
    compass_loan_details.all.count
  end

  def total_upb
    compass_loan_details.inject(0) { |sum,loan| sum += loan.upb }
  end

  def party_role_identifier
    '99999398668'
  end
end
