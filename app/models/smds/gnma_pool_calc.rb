class Smds::GnmaPoolCalc < ::DatabaseDatamart
  self.table_name_prefix += 'smds_' unless self.table_name_prefix.include?('smds')

  def self.primary_key
    'pool_number'
  end

  CREATE_VIEW_SQL = <<-eos
    SELECT -- P01 record type
           CLD.InvestorCommitNbr     AS pool_number,
           DATEADD(DAY, 1 - DAY(MAX(CLD.InvestorRclExpDt)), MAX(CLD.InvestorRclExpDt))
                                     AS issue_date,
           MAX(CLD.InvestorRclExpDt) AS settlement_date,
           SUM(CLD.UPB)              AS original_aggregate_amount,
           MIN(CLD.FinalNoteRate)    AS low_rate,
           MAX(CLD.FinalNoteRate)    AS high_rate,
           -- P02 record type
           MIN(CLD.FirstPmtDt)       AS payment_date,
           MAX(CLD.MaturityDt)       AS maturity_date,
           DATEADD(DAY, 1 - DAY(MAX(CLD.InvestorRclExpDt)), MAX(CLD.InvestorRclExpDt))
                                     AS unpaid_date,
           MAX(CLD.LnAmortTerm) / 12 AS term,
           COUNT(CLD.LnNbr)          AS number_of_loans
    FROM CTM.smds.SMDSCompassLoanDetails CLD
    WHERE CLD.InvestorCommitNbr LIKE 'GE%'
    GROUP BY CLD.InvestorCommitNbr
  eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

end
