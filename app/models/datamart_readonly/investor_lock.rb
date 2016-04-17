class InvestorLock < DatabaseDatamartReadonly
  belongs_to :loan_general

  def self.unique_names
    InvestorLock.where('investor_lock_expires_on >= ?', 1.year.ago).select(:investor_name).map(&:investor_name).uniq.compact
  end

  def self.sqlserver_create_view
    <<-eos
      SELECT
        INVESTOR_LOCK_id                AS id,
        loanGeneral_Id                  AS loan_general_id,
        [InvestorLabel]                 AS investor_label,
        [InvestorLoanIdentifier]        AS investor_loan_id,
        [InvestorLockDate]              AS investor_locked_on,
        [InvestorLockExpirationDate]    AS investor_lock_expires_on,
        [InvestorName]                  AS investor_name
      FROM       LENDER_LOAN_SERVICE.[dbo].[INVESTOR_LOCK]
    eos
  end
end

# [BranchInvestorIdentifier] [varchar](50) NULL,
# [CommitmentReferenceIdentifier] [varchar](50) NULL,
# [CommunityReinvestmentAct] [bit] NULL,
# [DeliveryExpDate] [datetime] NULL,
# [DerivativeLoanCommitmentPrice] [money] NULL,
# [FinalBranchMargin] [money] NULL,
# [GrossSellPrice] [money] NULL,
# [GuarantorFeePercent] [decimal](8, 4) NULL,
# [InvestorLoanIdentifier] [varchar](50) NULL,
# [InvestorMERSOrganizationIdentifier] [varchar](10) NULL,
# [InvestorPurchaserType] [varchar](300) NULL,
# [InvestorWarehouseInvestorCode] [varchar](4) NULL,
# [LenderMarginPercent] [decimal](8, 4) NULL,
# [MarkToTradePricePercent] [decimal](8, 4) NULL,
# [NetSellPrice] [money] NULL,
# [RateLockType] [varchar](20) NULL,
# [ServiceReleasePremium] [money] NULL,
# [ServicingFeePercent] [decimal](8, 4) NULL,
# [TargetedBranchMargin] [money] NULL,
# [TargetedOriginationFee] [money] NULL,
# [TargetedProcessingFee] [money] NULL,
# [TargetedUnderwritingFee] [money] NULL,
# [TemporarilyAssigned] [bit] NULL,
# [TradeIdentifier] [int] NULL,
# [TradeReferenceIdentifier] [varchar](50) NULL,
