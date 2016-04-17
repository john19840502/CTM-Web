builder.LOAN_IDENTIFIERS do
  builder.LOAN_IDENTIFIER do
    if loan.try(:delivery_type).eql?('FHLB')
      builder.InvestorCommitmentIdentifier loan.InvestorCommitmentIdentifier
    else
      builder.InvestorContractIdentifier loan.short_investor_contract_identifier
    end
  end
  builder.LOAN_IDENTIFIER do
    builder.MERS_MINIdentifier loan['MERS_MINIdentifier']
  end
  builder.LOAN_IDENTIFIER do
    builder.SellerLoanIdentifier loan['SellerLoanIdentifier']
  end
end
