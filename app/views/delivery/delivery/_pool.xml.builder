builder.POOL do
  builder.POOL_DETAIL do
    builder.PoolAccrualRateStructureType pool.pool_accrual_rate_structure_type
    builder.PoolAmortizationType pool.pool_amortization_type
    builder.PoolAssumabilityIndicator pool.pool_assumability_indicator
    builder.PoolBalloonIndicator pool.pool_balloon_indicator
    builder.PoolFixedServicingFeePercent pool.pool_fixed_servicing_fee_percent
    builder.PoolIdentifier pool.pool_identifier
    builder.PoolInterestAndPaymentAdjustmentIndexLeadDaysCount '45'
    builder.PoolInterestOnlyIndicator pool.pool_interest_only_indicator
    builder.PoolInterestRateRoundingPercent '0.125'
    builder.PoolInterestRateRoundingType 'Nearest'
    builder.PoolInvestorProductPlanIdentifier pool.investor_product_plan_identifier
    builder.PoolIssueDate l pool.pool_issue_date, :format => :yyyy_mm_dd if pool.pool_issue_date.present?
    builder.PoolMortgageType pool.pool_mortgage_type
    builder.PoolOwnershipPercent pool.pool_ownership_percent
    if pool.is_fhlb?
      builder.PoolScheduledRemittancePaymentDay pool.pool_scheduled_remittance_payment_day if pool.pool_scheduled_remittance_payment_day
    else
      builder.PoolScheduledRemittancePaymentDay "---#{pool.pool_scheduled_remittance_payment_day}" if pool.pool_scheduled_remittance_payment_day
    end
    builder.PoolSecurityIssueDateInterestRatePercent pool.pool_security_issue_date_interest_rate_percent
    builder.PoolStructureType pool.pool_structure_type
    builder.PoolSuffixIdentifier pool.pool_suffix_identifier
    builder.SecurityTradeBookEntryDate l pool.security_trade_book_entry_date, :format => :yyyy_mm_dd if pool.security_trade_book_entry_date.present?
  end
end
