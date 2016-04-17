builder.LOAN("LoanRoleType" => 'RelatedLoan') do
  if loan.heloc?
    builder.HELOC do
      builder.HELOC_OCCURRENCES do
        builder.HELOC_OCCURRENCE do
          builder.CurrentHELOCMaximumBalanceAmount loan.current_heloc_maximum_balance_amount
          builder.HELOCBalanceAmount loan.unpaid_balance_amount
        end
      end
    end
  end
  builder.LOAN_DETAIL do
    builder.HELOCIndicator loan.heloc?
  end
  builder.LOAN_STATE do
    builder.LoanStateDate Date.today
    builder.LoanStateType 'Current'
  end
  if loan.secondary_mortgage?
    builder.PAYMENT do
      builder.PAYMENT_SUMMARY do
        builder.UPBAmount loan.unpaid_balance_amount
      end
    end
  end
  builder.TERMS_OF_MORTGAGE do
    builder.LienPriorityType loan.lien_position
    builder.MortgageType 'Conventional'
  end
end