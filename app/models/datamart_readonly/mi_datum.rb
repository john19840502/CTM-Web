class MiDatum < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT 
        MI_DATA_id                AS id,
        loanGeneral_Id            AS loan_general_id,
        MIProgram_1003            AS mi_program_1003,
        MICertificateIdentifier   AS mi_certificate_identifier,
        MICompanyId_1003          AS mi_company_id
      FROM LENDER_LOAN_SERVICE.dbo.[MI_DATA]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end


# MI_DATA_id
# loanGeneral_Id
# MI_FHAUpfrontPremiumAmount
# MIInitialPremiumRatePercent
# MIInitialPremiumAmount
# MIDurationType
# MIEscrowIncludedInAggregateIndicator
# MIRenewalCalculationType
# MIPremiumFromClosingAmount
# MICollectedNumberOfMonthsCount
# MIInitialPremiumRateDurationMonths
# MICompanyName
# MICertificateIdentifier
# MIScheduledTerminationDate
# MILenderPaidRatePercent
# MIFinancedSinglePremiumAmount
# MIAdjusterIndicator
# UWMICompanyName
# MIProgram_1003
# MICompanyId_1003
# MIUserDefinedRate_1003
