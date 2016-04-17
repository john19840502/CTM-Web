class Smds::GnmaPool < DatabaseRailway

  has_many :gnma_loans, :class_name => 'Smds::GnmaLoan', foreign_key: :pool_number, primary_key: :pool_number

  self.table_name_prefix += 'smds_' unless self.table_name_prefix.include?('smds')

  coerce_sqlserver_date :issue_date
  coerce_sqlserver_date :settlement_date
  coerce_sqlserver_date :payment_date
  coerce_sqlserver_date :maturity_date
  coerce_sqlserver_date :unpaid_date
  coerce_sqlserver_date :security_change_date

  # These defaults represent constant values in the GinnieNET file
  default_values  issuer_id: '4306',
                  custodian_id: '000350',
                  pool_type: 'SF',
                  method: 'CD',
                  certification_and_agreement: '2',
                  sent_11711: '2',
                  pi_bank_id: '071001737',
                  aba_number: '053000196',
                  deliver_to: 'BK AMERICA NC / 2E21',
                  frb_description_2: 'Ref: 650771.1  FC: Cole Taylor Bank',
                  ti_bank_id: '071001737'

  # format A|B[|C]
  # A is type F=filler(space), X=Alphanumeric, D=Date(YYYYMMDD), 9=Numeric
  # B is length
  # C is optional and is the number of decimal places for floats (no C means it's an integer)

  MASTER_AGREEMENT_FILE_SPEC = {
    'A01' => {
      :filler_1                  => 'F|1',
      :ginnie_pool_number        => 'X|6',
      :issue_type                => 'X|1',
      :pool_type                 => 'X|2',
      :ti_account_number         => 'X|20',
      :ti_bank_id                => 'X|9',
      :filler_2                  => 'F|38'
    }
  }

  SUBSCRIBER_FILE_SPEC = {
    'S01' => {
      :filler_1                  => 'F|1',
      :ginnie_pool_number        => 'X|6',
      :issue_type                => 'X|1',
      :pool_type                 => 'X|2',
      :position                  => '9|10|2', #
      :frb_description_1         => 'X|48',   #
      :filler_2                  => 'F|6'
      },
    'S02' => {
      :aba_number                => 'X|9',    #
      :deliver_to                => 'X|20',   #
      :frb_description_2         => 'X|42',   #
      :filler_1                  => 'F|6'
    }
  }

  FILE_SPEC = {
    'P01' => {
      :filler_1                  => 'F|1',
      :ginnie_pool_number        => 'X|6',
      :issue_type                => 'X|1',
      :pool_type                 => 'X|2',
      :issuer_id                 => 'X|4',
      :custodian_id              => 'X|6',
      :issue_date                => 'D|8',
      :settlement_date           => 'D|8',
      :original_aggregate_amount => '9|11|2',
      :security_rate             => '9|2|3',
      :low_rate                  => '9|2|3',
      :high_rate                 => '9|2|3',
      :method                    => 'X|2',
      :lookback_period           => '9|2',
      :filler_2                  => 'F|5'
      },
    'P02' => {
      :ginnie_payment_date         => 'D|8',
      :ginnie_maturity_date        => 'D|8',
      :unpaid_date                 => 'D|8',
      :term                        => '9|2',
      :tax_id                      => '9|9',
      :number_of_loans             => '9|5',
      :security_rate_margin        => '9|2|3',
      :security_change_date        => 'D|8',
      :filler_1                    => 'F|1',
      :arm_index_type              => 'X|1',
      :bond_finance                => 'X|1',
      :certification_and_agreement => '9|1',
      :sent_11711                  => '9|1',
      :filler_2                    => 'F|18'
      },
    'P05' => {
      :filler_1    => 'F|41',
      :new_issuer  => 'X|4',
      :subservicer => 'X|4',
      :filler_2    => 'F|28'
      },
    'P06' => {
      :filler_1          => 'F|40',
      :pi_account_number => 'X|20',
      :pi_bank_id        => 'X|9',
      :filler_2          => 'F|8'
    }
  }

  GNMA_ISSUE_TYPE =      [['X', 'Ginnie Mae I'],['C', 'Ginnie Mae II Custom'],['M', 'Ginnie Mae II Multiple Issuer']]
  GNMA_METHOD =          [['CD', 'Concurrent Date'],['IR', 'Internal Reserve']]
  GNMA_POOL_TYPE =       [['SF','SF - Single-Family' ],
                          ['MH','MH - Manufactured Home'],
                          ['GP','GP - Graduated-Payment - 5 year'],
                          ['GT','GT - Graduated-Payment - 10 year'],
                          ['GA','GA - Growing-Equity - 4%'],
                          ['GD','GD - Growing-Equity - Other'],
                          ['AR','AR - 1 Year ARM CMT'],
                          ['AQ','AQ - 1 Year ARM CMT'],
                          ['AT','AT - 3 Year ARM CMT'],
                          ['AF','AF - 5 Year ARM CMT'],
                          ['FT','FT - 5 Year ARM CMT'],
                          ['AS','AS - 7 Year ARM CMT'],
                          ['AX','AX - 10 Year ARM CMT'],
                          ['RL','RL - 1 Year ARM LIBOR'],
                          ['QL','QL - 1 Year ARM LIBOR'],
                          ['TL','TL - 3 Year ARM LIBOR'],
                          ['FL','FL - 5 Year ARM LIBOR'],
                          ['FB','FB - 5 Year ARM LIBOR'],
                          ['SL','SL - 7 Year ARM LIBOR'],
                          ['XL','XL - 10 Year ARM LIBOR'],
                          ['BD','BD - Buydown'],
                          ['FS','FS - FHA Secure'],
                          ['JM','JM - High Balance']]
  GNMA_ARM_INDEX_TYPE =  [['C', 'CMT'],['L', 'LIBOR']]
  GNMA_BOND_FINANCE =    [['B','Buider Bond'],['F','Final'],['C','Consolidation']]
  GNMA_CERT_AGREEMENT =  [[1,'Yes'],[2,'No']]
  GNMA_SENT_11711     =  [[1,'Yes'],[2,'No']]
  GNMA_LOOKBACK_PERIOD = [[30,30], [45,45]]

  GNMA_EDITABLE_COLUMNS = %w(gnma_pool_number issue_type pool_type tax_id security_rate lookback_period)

  FIELDS_WITH_FIXED_OPTIONS = {
    issue_type: GNMA_ISSUE_TYPE,
    method:     GNMA_METHOD,
    pool_type:  GNMA_POOL_TYPE,
    arm_index_type: GNMA_ARM_INDEX_TYPE,
    bond_finance: GNMA_BOND_FINANCE,
    certification_and_agreement: GNMA_CERT_AGREEMENT,
    sent_11711: GNMA_SENT_11711,
    lookback_period: GNMA_LOOKBACK_PERIOD
  }

  # checking if the pool is for FHLB
  def is_fhlb?
    false
  end

  ##FILTER BY DATE##
  require 'filter_by_date_model_methods'
  extend FilterByDateModelMethods

  def self.filter_by_date_method
    :settlement_date
  end
  ##FILTER BY DATE##

  def self.editable?(column_name)
    GNMA_EDITABLE_COLUMNS.include?(column_name)
  end

  def self.options_for_column(column_name)
    FIELDS_WITH_FIXED_OPTIONS[column_name.to_sym]
  end

  def self.input_type(column_name)
    return :select if FIELDS_WITH_FIXED_OPTIONS.has_key?(column_name.to_sym)
    return :date if column_name.end_with?("_date")
    :input
  end

  def self.display_with(column_name)
    return :l if column_name.end_with?("_date")
    return :number_to_currency if column_name == "original_aggregate_amount"
    return :number_to_percentage if column_name.end_with?("_rate")
  end

  def self.update_calcs(pool, calc)
    calc.attribute_names.each { |n|
      pool[n] = calc[n]
    }

    pool.save
  end

  def self.update_pools
    Smds::GnmaPoolCalc.all.each { |calc|
      pool = self.find_by_pool_number(calc.pool_number)
      pool = self.new if pool.nil?
      self.update_calcs(pool, calc)
    }
  end

  def pi_account_number
    case issue_type
    when 'X'; '5580000035'
    when 'C', 'M'; '5580000094'
    end
  end

  def ti_account_number
    case issue_type
    when 'X'; '5580000043'
    when 'C', 'M'; '5580000086'
    end
  end

  def loans ctrlr
    self.gnma_loans
  end

  def originator(user)
    self.exported_by = user.display_name
    self.exported_at = Time.now
    self.save
  end

  def ginnie_pool_number
    gnma_pool_number#self.pool_number[-6,6]
  end

  def is_ginnie_2_pool?
    return pool_number.starts_with? "GE2" if (:issue_type.nil?)
    return issue_type == 'C' || issue_type == 'M'
  end

  def ginnie_maturity_date
    day = is_ginnie_2_pool? ? 20 : 15
    return Date.new(self.maturity_date.year, self.maturity_date.month, day)
  end

  def ginnie_payment_date
    day = is_ginnie_2_pool? ? 20 : 15
    date = self.issue_date.next_month
    return Date.new(date.year, date.month, day)
  end

end