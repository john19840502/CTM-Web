builder.INVESTOR_LOAN_INFORMATION do
  builder.BaseGuarantyFeePercent loan.guarantee_fee_percent
  builder.GuarantyFeeAfterAlternatePaymentMethodPercent loan.guarantee_fee_percent
  builder.GuarantyFeePercent loan.guarantee_fee_percent
  builder.InvestorCollateralProgramIdentifier loan.InvestorCollateralProgramIdentifier
  builder.InvestorOwnershipPercent loan['InvestorOwnershipPercent']
  builder.InvestorProductPlanIdentifier loan.investor_product_plan_identifier
  if loan.try(:delivery_type).eql?('FHLB')
    builder.InvestorRemittanceDay loan.InvestorRemittanceDay 
  else
    builder.InvestorRemittanceDay "---#{loan['InvestorRemittanceDay']}" if loan['InvestorRemittanceDay']
  end
  builder.InvestorRemittanceType loan.InvestorRemittanceType
  builder.LoanAcquisitionScheduledUPBAmount loan.LoanAcquisitionScheduledUPBAmount
  builder.LoanDefaultLossPartyType loan.LoanDefaultLossPartyType
  builder.REOMarketingPartyType loan.REOMarketingPartyType
end
