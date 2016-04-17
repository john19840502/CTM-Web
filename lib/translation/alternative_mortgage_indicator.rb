module Translation
  class AlternativeMortgageIndicator
    attr_accessor :amortization_type

    def initialize(amortization_type)
      self.amortization_type = amortization_type
    end

    TRANSLATION =
        {
            'Fixed'                    => 0,
            'OtherAmortizationType'    => 1,
            'GraduatedPaymentMortgage' => 1,
            'AdjustableRate'           => 1,
            ''                         => 0,
            nil                        => 0
        }

    def translate
      TRANSLATION[amortization_type]
    end
  end
end