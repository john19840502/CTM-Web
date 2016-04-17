class FhaLoan < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT 
        FHA_LOAN_id                           AS id,
        loanGeneral_Id                        AS loan_general_id,
        FHAUpfrontMIPremiumPercent            AS upfront_mi_premium_percent,
        FHACoverageRenewalRatePercent         AS coverage_renewal_rate_percent
      FROM LENDER_LOAN_SERVICE.dbo.[FHA_LOAN]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end


# SELECT [FHA_LOAN_id]
#     ,[loanGeneral_Id]
#     ,[BorrowerFinancedFHADiscountPointsAmount]
#     ,[FHAAlimonyLiabilityTreatmentType]
#     ,[FHACoverageRenewalRatePercent]
#     ,[FHA_MIPremiumRefundAmount]
#     ,[FHAUpfrontMIPremiumPercent]
#     ,[_LenderIdentifier]
#     ,[_SponsorIdentifier]
#     ,[SectionOfActType]
#     ,[SalesAgreementDate]
#     ,[SponsoredOrigEIN]
# FROM [dbo].[FHA_LOAN]