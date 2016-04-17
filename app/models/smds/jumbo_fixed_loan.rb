module Smds
  class JumboFixedLoan < ::DatabaseDatamartReadonly
    self.table_name_prefix += 'smds_'

    def self.primary_key
      'loan_number'
    end

    has_one :credit_suisse_lock_file, primary_key: 'loan_number', foreign_key: 'seller_loan_number'
    has_one :credit_suisse_appraisal_file, primary_key: 'loan_number', foreign_key: 'lender_loan_number'
    has_one :credit_suisse_post_closing_file, primary_key: 'loan_number', foreign_key: 'seller_loan_number'
    has_one :credit_suisse_funding_file, primary_key: 'loan_number', foreign_key: 'loan_number'

    belongs_to :loan

    CREATE_VIEW_SQL = <<-eos
        SELECT LnNbr AS loan_number,
               InvestorName AS investor_name
        FROM CTM.smds.SMDSJumboFixedLoans
    eos

    def self.sqlserver_create_view
      CREATE_VIEW_SQL
    end

    def credit_suisse?
      investor_name == 'CSFB'
    end
  end
end
