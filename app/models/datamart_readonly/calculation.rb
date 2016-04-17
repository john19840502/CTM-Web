class Calculation < DatabaseDatamartReadonly
  belongs_to :loan_general


  def self.sqlserver_create_view
    <<-eos
      SELECT     CALCULATION_id AS id,
                loanGeneral_Id AS loan_general_id,
                _Name AS name,
                _Value AS value,
                BorrowerID AS borrower_id,
                Section AS section
      FROM       LENDER_LOAN_SERVICE.dbo.[CALCULATION]
    eos
  end

end
