builder.INVESTOR_FEATURES do
  loan.InvestorFeatureIdentifiers.each do |feature|
    builder.INVESTOR_FEATURE do
      builder.InvestorFeatureIdentifier feature
    end
  end
end
