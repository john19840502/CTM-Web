builder.INVESTOR_FEATURES do
  (1..6).each do |n|
    builder.INVESTOR_FEATURE do
      builder.InvestorFeatureIdentifier loan.InvestorFeatureIdentifier(n)
    end
  end
end