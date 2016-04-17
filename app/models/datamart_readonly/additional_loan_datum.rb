class AdditionalLoanDatum < DatabaseDatamartReadonly
  belongs_to :loan_general

  def self.sqlserver_create_view
    <<-eos
      SELECT
        ADDITIONAL_LOAN_DATA_id         AS id,
        loanGeneral_Id                  AS loan_general_id,
        APR                             AS apr,
        EmployeeLoanIndicator           AS employee_loan_indicator,
        [GSEPropertyType]               AS gse_property_type,
        LPMI                            AS lpmi,
        PipelineLoanStatusDescription   AS pipeline_loan_status_description,
        PipelineLockStatusDescription   AS pipeline_lock_status_description,
        ApplicationCreationDateTimeinAvista AS application_creation_date_time_in_avista,
        ActionDateTimeInAvista  AS action_date_time_in_avista,
        EscrowWaiverType                AS escrow_waiver_type
      FROM       LENDER_LOAN_SERVICE.dbo.[ADDITIONAL_LOAN_DATA]
    eos
  end
end

# [AccountExecutiveName] [varchar](50) NULL,
# [AccountExecutiveUserIdentifier] [int] NULL,
# [ActionDateTimeInAvista] [datetime] NULL,
# [ApplicationCreationDateTimeInAvista] [datetime] NULL,
# [ClosingRequestSubmittedDate] [datetime] NULL,
# [EscrowWaiverType] [varchar](20) NULL,
# [GSEPropertyType] [varchar](50) NULL,
# [HELOCProductIndicator] [bit] NULL,
# [HomeEquityTransactionReason] [varchar](50) NULL,
# [HomeEquityTransactionType] [varchar](20) NULL,
# [LeadConvertedToLoanDate] [datetime] NULL,
# [LoanDocumentationType] [varchar](100) NULL,
# [LoanIntention] [varchar](50) NULL,
# [NumberOfStories] [tinyint] NULL,
# [OutofTolerance] [bit] NULL,
# [ProductType] [varchar](50) NULL,
# [ProductVariation] [varchar](50) NULL,
# [SimultaneousDeliveryIndicator] [bit] NULL,
# [UpdatedByUserIdentifier] [int] NULL,
# [UpdatedByUserLoginIdentifier] [varchar](50) NULL,
# [UpdatedByUserName] [varchar](50) NULL,
