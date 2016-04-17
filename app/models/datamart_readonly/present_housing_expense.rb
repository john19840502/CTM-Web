class PresentHousingExpense < DatabaseDatamartReadonly
  belongs_to :loan_general

  def self.sqlserver_create_view
    <<-eos
      SELECT  PRESENT_HOUSING_EXPENSE_id  AS id,
                loanGeneral_Id                AS loan_general_id,
                [BorrowerID]                  AS borrower_id,
                HousingExpenseType            AS housing_expense_type,
                _PaymentAmount                AS payment_amount
      FROM    LENDER_LOAN_SERVICE.dbo.[PRESENT_HOUSING_EXPENSE]
    eos
  end

end
