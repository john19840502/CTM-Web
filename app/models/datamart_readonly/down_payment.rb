class DownPayment < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT
        DOWN_PAYMENT_id             AS id,
        loanGeneral_Id              AS loan_general_id,
        _Amount                     AS amount,
        _SourceDescription          AS source_description,
        _Type                       AS downpayment_type
      FROM       LENDER_LOAN_SERVICE.dbo.[DOWN_PAYMENT]
    eos
  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def self.fhlbc_dpp loan
    DownPayment.joins(:loan_general).where(source_description: 'FHLBC DPP', 
                                                loan_general: { lender_registration_id: loan.loan_num }).last
  end
end
