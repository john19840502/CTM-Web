builder.ADJUSTMENT do
  builder.INTEREST_RATE_ADJUSTMENT do
    builder.INDEX_RULES do
      builder.INDEX_RULE do
        builder.IndexSourceType loan.index_source_type
        builder.IndexSourceTypeOtherDescription loan.index_source_type_other_description
        builder.InterestAndPaymentAdjustmentIndexLeadDaysCount '45'
      end
    end
    builder.INTEREST_RATE_LIFETIME_ADJUSTMENT_RULE do
      builder.CeilingRatePercent loan.CeilingRatePercent
      builder.FirstRateChangePaymentEffectiveDate loan.FirstRateChangePaymentEffectiveDate
      builder.InterestRateRoundingPercent "0.125"
      builder.InterestRateRoundingType "Nearest"
      builder.MarginRatePercent loan.MarginRatePercent
    end
    builder.INTEREST_RATE_PER_CHANGE_ADJUSTMENT_RULES do
      builder.INTEREST_RATE_PER_CHANGE_ADJUSTMENT_RULE do
        builder.AdjustmentRuleType "First"
        builder.PerChangeMaximumDecreaseRatePercent loan.FirstMaximumRateChangePercent
        builder.PerChangeMaximumIncreaseRatePercent loan.FirstMaximumRateChangePercent
        builder.PerChangeRateAdjustmentEffectiveDate loan.FirstPerChangeRateAdjustmentEffectiveDate
        builder.PerChangeRateAdjustmentFrequencyMonthsCount loan.SubsequentPerChangeRateAdjustmentFrequencyMonthsCount
      end
      builder.INTEREST_RATE_PER_CHANGE_ADJUSTMENT_RULE do
        builder.AdjustmentRuleType "Subsequent"
        builder.PerChangeMaximumDecreaseRatePercent loan.SubsequentMaximumRateChangePercent
        builder.PerChangeMaximumIncreaseRatePercent loan.SubsequentMaximumRateChangePercent
        builder.PerChangeRateAdjustmentEffectiveDate loan.SubsequentPerChangeRateAdjustmentEffectiveDate
        builder.PerChangeRateAdjustmentFrequencyMonthsCount loan.SubsequentPerChangeRateAdjustmentFrequencyMonthsCount
      end
    end
  end
end