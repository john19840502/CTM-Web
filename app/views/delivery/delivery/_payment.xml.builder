builder.PAYMENT do
  if loan.arm?
    builder.PAYMENT_COMPONENT_BREAKOUTS do
      builder.PAYMENT_COMPONENT_BREAKOUT do
        builder.PrincipalAndInterestPaymentAmount loan.InitialPrincipalAndInterestPaymentAmount
      end
    end
  end
  builder.PAYMENT_SUMMARY do
    builder.AggregateLoanCurtailmentAmount loan.AggregateLoanCurtailmentAmount
    builder.LastPaidInstallmentDueDate loan.LastPaidInstallmentDueDate
    builder.UPBAmount loan.UPBAmount1
  end
end
