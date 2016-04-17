builder.LOAN("LoanRoleType" => "SubjectLoan") do
  render partial: 'loan_at_closing/adjustment', locals: { loan: loan, builder: builder } if loan.arm?
  render partial: 'loan_at_closing/amortization', locals: { loan: loan, builder: builder }
  render partial: 'loan_at_closing/buydown', locals: { loan: loan, builder: builder }
  builder.CONSTRUCTION do
    builder.ConstructionLoanType loan.ConstructionLoanType
  end
  render partial: 'loan_at_closing/form_specific_contents', locals: { loan: loan, builder: builder }
  builder.GOVERNMENT_LOAN do
    builder.SectionOfActType loan.SectionOfActType
  end
  builder.HMDA_LOAN do
    builder.HMDA_HOEPALoanStatusIndicator loan.HMDA_HOEPALoanStatusIndicator
    builder.HMDARateSpreadPercent loan.HMDARateSpreadPercent
  end
  builder.INTEREST_CALCULATION do
    builder.INTEREST_CALCULATION_RULES do
      builder.INTEREST_CALCULATION_RULE do
        builder.InterestCalculationPeriodType 'Month'
        builder.InterestCalculationType 'Simple'
      end
    end
  end
  builder.INVESTOR_LOAN_INFORMATION do
    builder.RelatedInvestorLoanIdentifier loan.RelatedInvestorLoanIdentifier
    builder.RelatedLoanInvestorType loan.RelatedLoanInvestorType
  end
  render partial: 'loan_at_closing/loan_detail', locals: { loan: loan, builder: builder }
  builder.LOAN_LEVEL_CREDIT do
    builder.LOAN_LEVEL_CREDIT_DETAIL do
      builder.LoanLevelCreditScoreSelectionMethodType loan.LoanLevelCreditScoreSelectionMethodType
      builder.LoanLevelCreditScoreValue loan.LoanLevelCreditScore
    end
  end
  builder.LOAN_STATE do
    builder.LoanStateDate loan.LoanStateDate1
    builder.LoanStateType 'AtClosing'
  end
  builder.LTV do
    builder.BaseLTVRatioPercent loan.BaseLTVRatioPercent
    builder.LTVRatioPercent loan.LTVRatioPercent
  end
  builder.MATURITY do
    builder.MATURITY_RULE do
      builder.LoanMaturityDate loan.LoanMaturityDate
      builder.LoanMaturityPeriodCount loan.LoanMaturityPeriodCount
      builder.LoanMaturityPeriodType loan.LoanMaturityPeriodType
    end
  end
  builder.PAYMENT do
    builder.PAYMENT_RULE do
      builder.InitialPrincipalAndInterestPaymentAmount loan.InitialPrincipalAndInterestPaymentAmount
      builder.PaymentFrequencyType loan.PaymentFrequencyType
      builder.ScheduledFirstPaymentDate loan.ScheduledFirstPaymentDate
    end
  end
  builder.QUALIFICATION do
    builder.BorrowerReservesMonthlyPaymentCount loan.BorrowerReservesMonthlyPaymentCount
    builder.TotalLiabilitiesMonthlyPaymentAmount loan.TotalLiabilitiesMonthlyPaymentAmount
    builder.TotalMonthlyIncomeAmount loan.TotalMonthlyIncomeAmount
    builder.TotalMonthlyProposedHousingExpenseAmount loan.TotalMonthlyProposedHousingExpenseAmount
  end
  builder.REFINANCE do
    builder.RefinanceCashOutAmount loan.RefinanceCashOutAmount
    builder.RefinanceCashOutDeterminationType loan.RefinanceCashOutDeterminationType
  end
  builder.SELECTED_LOAN_PRODUCT do
    builder.PRICE_LOCKS do
      builder.PRICE_LOCK do
        builder.PriceLockDatetime loan.PriceLockDatetime
      end
    end
  end
  builder.TERMS_OF_MORTGAGE do
    builder.DisclosedIndexRatePercent loan.DisclosedIndexRatePercent
    builder.LienPriorityType loan.LienPriorityType1
    builder.LoanPurposeType loan.LoanPurposeType
    builder.MortgageType loan.MortgageType1
    builder.NoteAmount loan.NoteAmount
    builder.NoteDate loan.NoteDate
    builder.NoteRatePercent loan.NoteRatePercent
  end
  builder.UNDERWRITING do
    builder.AUTOMATED_UNDERWRITINGS do
      builder.AUTOMATED_UNDERWRITING do
        builder.AutomatedUnderwritingCaseIdentifier loan.AutomatedUnderwritingCaseIdentifier
        builder.AutomatedUnderwritingRecommendationDescription loan.AutomatedUnderwritingRecommendationDescription
        builder.AutomatedUnderwritingSystemType loan.AutomatedUnderwritingSystemType
      end
    end
    builder.UNDERWRITING_DETAIL do
      builder.LoanManualUnderwritingIndicator loan.LoanManualUnderwritingIndicator
    end
  end
end
