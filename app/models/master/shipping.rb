require 'ctm/ms_sql_view'
module Master
  class Shipping < Master::Avista::ReadOnly
    extend ::CTM::MSSqlView

    # relations
    belongs_to :loan, class_name: 'Master::Loan'

    has_many :loan_boardings, foreign_key: 'loan_id', primary_key: 'loan_id'

    from 'SHIPPING', as: 'shipping'

    field :loan_id,             column: 'loanGeneral_Id'
    field :cleared_date,        column: '_ClearedDate'
    field :servicer,            column: '_Servicer'
    field :servicer_loan_number, column: '_ServicerLoanNumber'
    field :shipped_to_servicer_on, column: '_ShippedToServicerDate'

    alias_attribute :loan_general_id, :loan_id

    # reverted because it was adding 8000 records to the loi file
    def self.available_for_boarding
      sql = <<-EOS
        SELECT sh.* FROM #{Master::Shipping.table_name} sh 
        LEFT OUTER JOIN LENDER_LOAN_SERVICE.dbo.MERS mers          ON mers.loanGeneral_id = sh.loan_id 
        LEFT OUTER JOIN LENDER_LOAN_SERVICE.dbo.ACCOUNT_INFO ai    ON ai.loanGeneral_id = sh.loan_id
        LEFT OUTER JOIN LENDER_LOAN_SERVICE.dbo.LOCK_LOAN_DATA lld ON lld.loanGeneral_id = sh.loan_id
        LEFT OUTER JOIN LENDER_LOAN_SERVICE.dbo.LOCK_PRICE lp      ON lp.loanGeneral_id = sh.loan_id
        WHERE 
            cleared_date IS NOT NULL 
          AND 
            (   
              (mers._SubServicer = 'Cole Taylor Bank' OR mers._SubServicer = 'MB Financial Bank, N.A.')
              OR 
              (
                ISNULL(mers._SubServicer, '') = '' 
                AND 
                (servicer = 'Cole Taylor Bank' OR servicer = 'MB Financial Bank, N.A.')
              )
            )
          AND
            shipped_to_servicer_on IS NULL

      EOS

      self.find_by_sql(sql)
    end

    # TODO: Figure out how to make it so we don't need to declare this
    # in each model and just keep it in the parent module.
    def self.sqlserver_create_view
      self.build_query
    end

  end
end
