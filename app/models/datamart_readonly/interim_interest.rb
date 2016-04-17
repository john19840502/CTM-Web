class InterimInterest < DatabaseDatamartReadonly
  belongs_to :loan_general
  has_one :cond_pending_review, through: :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT
        INTERIM_INTEREST_id               AS id,
        loanGeneral_Id                    AS loan_general_id,
        [_PerDiemCalculationMethodType]   AS per_diem_calculation_method_type

      FROM       LENDER_LOAN_SERVICE.dbo.[INTERIM_INTEREST]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end

  # [_PaidFromDate] [smalldatetime] NULL,
  # [_PaidNumberOfDays] [int] NULL,
  # [_PaidThroughDate] [smalldatetime] NULL,
  # [_PerDiemCalculationMethodType] [varchar](10) NULL,
  # [_PerDiemPaymentOptionType] [varchar](20) NULL,
  # [_SinglePerDiemAmount] [money] NULL,
  # [_TotalPerDiemAmount] [money] NULL
