class HmdaRace < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL =  <<-eos
      SELECT     HMDA_RACE_id     AS id,
                loanGeneral_id                      AS loan_general_id,
                BorrowerID                          AS borrower_id,
                _Type                               AS hmda_race_type
      FROM       LENDER_LOAN_SERVICE.dbo.[HMDA_RACE]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
