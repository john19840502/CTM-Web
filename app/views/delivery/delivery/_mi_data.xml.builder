builder.MI_DATA do
  builder.MI_DATA_DETAIL do
    builder.LenderPaidMIInterestRateAdjustmentPercent loan.mortgage_insurance.lender_paid_rate_adjustment
    builder.MICertificateIdentifier loan.mortgage_insurance.certificate_identifier
    builder.MICompanyNameType loan.mortgage_insurance.company_name
    if loan.delivery_type == "FHLMC" 
      builder.MICoveragePercent loan.mortgage_insurance.coverage_percent
    else
      builder.MICoveragePercent loan.mortgage_insurance.coverage_percent_fnma
    end
    builder.MIPremiumFinancedAmount loan.mortgage_insurance.premium_financed_amount
    builder.MIPremiumFinancedIndicator loan.mortgage_insurance.premium_financed_indicator
    builder.MIPremiumSourceType loan.mortgage_insurance.premium_source
    builder.PrimaryMIAbsenceReasonType loan.mortgage_insurance.primary_absence_reason
    builder.PrimaryMIAbsenceReasonTypeOtherDescription loan.mortgage_insurance.primary_absence_reason_other_desc if loan.delivery_type == "FHLMC" 
  end
end
