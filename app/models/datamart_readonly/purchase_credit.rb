class PurchaseCredit < DatabaseDatamartReadonly
  belongs_to :loan_general


  def self.sqlserver_create_view
    <<-eos
      SELECT     PURCHASE_CREDIT_id AS id,
                loanGeneral_Id AS loan_general_id,
                _Amount AS amount,
                _SourceType AS source_type,
                _Type AS credit_type
      FROM       LENDER_LOAN_SERVICE.dbo.[PURCHASE_CREDIT]
    eos
  end

end
