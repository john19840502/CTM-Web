class PaidByFee < DatabaseDatamartReadonly
  belongs_to :loan_general

  def self.sqlserver_create_view
    <<-eos
      SELECT
        PAIDBYFEE_id                AS id,
        loanGeneral_Id              AS loan_general_id,
        HUD_LINE_id                 AS hud_line_id,
        [_PayAmount]                AS pay_amount,
        [_PaidByType]               AS paid_by_type
      FROM       LENDER_LOAN_SERVICE.dbo.[PAIDBYFEE]
    eos
  end
end