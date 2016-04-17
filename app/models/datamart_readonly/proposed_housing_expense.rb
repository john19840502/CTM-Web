class ProposedHousingExpense < DatabaseDatamartReadonly
  belongs_to :loan_general


  def self.sqlserver_create_view
    <<-eos
      SELECT  PROPOSED_HOUSING_EXPENSE_id  AS id,
                loanGeneral_Id                AS loan_general_id,
                HousingExpenseType            AS housing_expense_type,
                _PaymentAmount                AS payment_amount,
                MICoveragePercent1003         AS mi_coverage_percent
      FROM    LENDER_LOAN_SERVICE.dbo.[PROPOSED_HOUSING_EXPENSE]
    eos
  end

end
