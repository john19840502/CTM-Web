class Arm < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos

      SELECT 
        ARM_id AS id,
        loanGeneral_Id                  AS loan_general_id,
        [_IndexCurrentValuePercent]     AS index_current_value_percent,
        _IndexMarginPercent             AS index_margin_percent,
        _IndexType                      AS index_type,
        _QualifyingRatePercent          AS qualifying_rate_percent

      FROM       LENDER_LOAN_SERVICE.dbo.[ARM]
    eos
  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end


  # [ARM_id]
  # ,[loanGeneral_Id]
  # ,[_IndexMarginPercent]
  # ,[_IndexType]
  # ,[_QualifyingRatePercent]
  # ,[PaymentAdjustmentLifetimeCapAmount]
  # ,[PaymentAdjustmentLifetimeCapPercent]
  # ,[RateAdjustmentLifetimeCapPercent]
  # ,[_LifetimeCapRate]
  # ,[_LifetimeFloorPercent]
  # ,[_ConversionOptionIndicator]
end
