class CurrentIncome < DatabaseDatamartReadonly
  belongs_to :loan_general

  def self.sqlserver_create_view
    <<-eos
      SELECT     CURRENT_INCOME_id      AS id,
                 LoanGeneral_Id         AS loan_general_id,
                 [BorrowerID]           AS borrower_id,
                 [IncomeType]           AS income_type,
                 [_MonthlyTotalAmount]  AS monthly_total_amount
      FROM       LENDER_LOAN_SERVICE.dbo.[CURRENT_INCOME]
    eos
  end

end
