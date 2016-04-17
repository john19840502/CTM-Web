class RateAdjustment < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT
        RATE_ADJUSTMENT_id               AS id,
        loanGeneral_Id                   AS loan_general_id,
        _SubsequentCapPercent            AS subsequent_cap_percent,
        _FirstChangeCapRate              AS first_change_cap_rate,
        SubsequentRateAdjustmentMonths   AS subsequent_rate_adjustment_months,
        FirstRateAdjustmentMonths        AS first_rate_adjustment_months,
        [LifetimeCapPercent]             AS lifetime_cap_percent

      FROM       LENDER_LOAN_SERVICE.dbo.[RATE_ADJUSTMENT]
    eos
  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end

#   [FirstRateAdjustmentMonths] [int] NULL,
#   [_CalculationType] [varchar](50) NULL,
#   [_DurationMonths] [int] NULL,
#   [_Percent] [decimal](8, 4) NULL,
#   [_PeriodNumber] [int] NULL,
#   [_SubsequentCapPercent] [decimal](8, 4) NULL,
#   [SubsequentRateAdjustmentMonths] [int] NULL,
#   [_FirstChangeCapRate] [decimal](8, 4) NULL,
#   [FirstRateAdjustmentDate] [smalldatetime] NULL
