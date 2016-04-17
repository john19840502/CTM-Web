class VaLoan < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT 
        VA_LOAN_id                           AS id,
        loanGeneral_Id                       AS loan_general_id,
        FundingFeeExemptIndicator            AS funding_fee_exempt_indicator,
        BorrowerFundingFeePercent            AS borrower_funding_fee_percent
      FROM LENDER_LOAN_SERVICE.dbo.[VA_LOAN]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end


# VA_LOAN_id
# loanGeneral_Id
# VABorrowerCoBorrowerMarriedIndicator
# BorrowerFundingFeePercent
# VAEntitlementAmount
# VAMaintenanceExpenseMonthlyAmount
# VAUtilityExpenseMonthlyAmount]
# VAResidualIncomeAmount
# LoanCode
# FundingFeeExemptIndicator
# _LenderIdentifier
# _SponsorIdentifier
# ExceptionForResidualIncomeIndicator
