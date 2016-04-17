builder.LOAN('LoanRoleType' => 'SubjectLoan') do
  render partial: 'delivery/adjustment', locals: { loan: loan, builder: builder } if loan.arm?
  render partial: 'delivery/investor_features', locals: { loan: loan, builder: builder }
  render partial: 'investor_loan_information', locals: { loan: loan, builder: builder }
  builder.LOAN_DETAIL do
    builder.CurrentInterestRatePercent loan.CurrentInterestRatePercent if loan.arm?
    builder.InitialFixedPeriodEffectiveMonthsCount loan.FirstPerChangeRateAdjustmentFrequencyMonthsCount if loan.arm?
    builder.MortgageModificationIndicator loan['MortgageModificationIndicator']
  end
  render partial: 'loan_identifiers', locals: { loan: loan, builder: builder }
  builder.LOAN_PROGRAMS do
    builder.LOAN_PROGRAM do
      builder.LoanProgramIdentifier loan['LoanProgramIdentifier']
    end
  end
  builder.LOAN_STATE do
    builder.LoanStateDate Date.today
    builder.LoanStateType 'Current'
  end
  render partial: 'delivery/mi_data', locals: { loan: loan, builder: builder }
  render partial: 'delivery/payment', locals: { loan: loan, builder: builder }
  builder.SELECTED_LOAN_PRODUCT do
    builder.LOAN_PRODUCT_DETAIL do
      builder.RefinanceProgramIdentifier loan['RefinanceProgramIdentifier']
    end
  end
  builder.SERVICING do
    builder.DELINQUENCY_SUMMARY do
      builder.DelinquentPaymentsOverPastTwelveMonthsCount loan['DelinquentPaymentsOverPastTwelveMonthsCount']
    end
  end
end