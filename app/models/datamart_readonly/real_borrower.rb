class RealBorrower < DatabaseDatamartReadonly
  belongs_to :loan_general

  def self.sqlserver_create_view
    <<-eos
      SELECT
        BORROWER_id AS id,
        loanGeneral_Id AS loan_general_id,
        BorrowerID AS ranking,
        _FirstName AS first_name,
        _MiddleName AS middle_name,
        _LastName AS last_name,
        _NameSuffix AS suffix,
        CreditScore AS credit_score
      FROM       LENDER_LOAN_SERVICE.dbo.[BORROWER]
    eos
  end

  def position
    ranking[-1]
  end

  def borrower_last_name
    "#{last_name}"
  end
end
