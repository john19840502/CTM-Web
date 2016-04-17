builder.LOAN_IDENTIFIERS do
  builder.LOAN_IDENTIFIER do
    builder.InvestorCommitmentIdentifier loan['InvestorCommitmentIdentifier']
  end
  builder.LOAN_IDENTIFIER do
    builder.MERS_MINIdentifier loan['MERS_MINIdentifier']
  end
  builder.LOAN_IDENTIFIER do
    builder.SellerLoanIdentifier loan['SellerLoanIdentifier']
  end
end