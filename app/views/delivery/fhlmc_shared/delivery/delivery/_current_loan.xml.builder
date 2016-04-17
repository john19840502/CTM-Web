builder.LOAN("LoanRoleType" => "SubjectLoan") do
  render partial: 'delivery/adjustment', locals: { loan: loan, builder: builder } if loan.arm?
  builder.CLOSING_INFORMATION do
    builder.COLLECTED_OTHER_FUNDS do
      builder.COLLECTED_OTHER_FUND do
        builder.OtherFundsCollectedAtClosingAmount loan.OtherFundsCollectedAtClosingAmount
        builder.OtherFundsCollectedAtClosingType loan.OtherFundsCollectedAtClosingType
      end
    end
  end
  builder.ESCROW do
    builder.ESCROW_ITEMS do
      loan.escrow_items.each do |escrow_item|
        builder.ESCROW_ITEM do
          builder.ESCROW_ITEM_DETAIL do
            builder.EscrowItemType escrow_item[:type].presence
            builder.EscrowMonthlyPaymentAmount escrow_item[:amount].presence
          end
        end
      end
    end
  end
  render partial: 'investor_features', locals: { loan: loan, builder: builder }
  render partial: 'investor_loan_information', locals: { loan: loan, builder: builder }
  builder.LOAN_DETAIL do
    builder.CurrentInterestRatePercent loan.CurrentInterestRatePercent if loan.arm?
    builder.MortgageModificationIndicator loan.MortgageModificationIndicator
  end
  render partial: 'loan_identifiers', locals: { loan: loan, builder: builder }
  builder.LOAN_STATE do
    builder.LoanStateDate Date.today
    builder.LoanStateType 'Current'
  end

  render partial: 'delivery/mi_data', locals: { loan: loan, builder: builder} 
  
  render partial: 'payment', locals: { loan: loan, builder: builder }
  
  builder.SELECTED_LOAN_PRODUCT do
    builder.LOAN_PRODUCT_DETAIL do
      builder.RefinanceProgramIdentifier loan.RefinanceProgramIdentifier
    end
  end
  builder.SERVICING do
    builder.DELINQUENCY_SUMMARY do
      builder.DelinquentPaymentsOverPastTwelveMonthsCount loan.DelinquentPaymentsOverPastTwelveMonthsCount
    end
  end
end
