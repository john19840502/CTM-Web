builder.BUYDOWN do
  builder.BUYDOWN_CONTRIBUTORS do
    builder.BUYDOWN_CONTRIBUTOR do
      builder.BUYDOWN_CONTRIBUTOR_DETAIL do
        builder.BuydownContributorType loan.BuydownContributorType
      end
    end
  end
  builder.BUYDOWN_RULE do
    builder.BuydownInitialDiscountPercent loan.BuydownInitialDiscountPercent
    builder.BuydownChangeFrequencyMonthsCount loan.BuydownChangeFrequencyMonthsCount
    builder.BuydownIncreaseRatePercent loan.BuydownIncreaseRatePercent
    builder.BuydownDurationMonthsCount loan.BuydownDurationMonthsCount
  end
end