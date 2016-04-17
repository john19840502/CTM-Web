builder.LOAN_IDENTIFIERS do
  builder.LOAN_IDENTIFIER do
    builder.MERS_MINIdentifier loan.MERS_MINIdentifier
  end
  builder.LOAN_IDENTIFIER do
    builder.SellerLoanIdentifier loan.SellerLoanIdentifier
  end
#  builder.LOAN_IDENTIFIER do
  #  TODO: htis is new for freddie
#    builder.ServicerLoanIdentifier loan.ServicerLoanIdentifier
#  end
end
