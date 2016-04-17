module Translation
  class LoanTypeNumber
    attr_accessor :mortgage_type, :mi_indicator
    def initialize(options)
      @mortgage_type = options[:mortgage_type]
      @mi_indicator = options[:mi_indicator]
    end

    CONVENTIONAL_MI_TRANSLATION =
        { false => 1,
          true  => 8}

    TRANSLATION =
      {
          'Conventional'              => CONVENTIONAL_MI_TRANSLATION,
          'FHA'                       => 2,
          'FarmersHomeAdministration' => 9,
          'VA'                        => 3,
          'Other'                     => 9,
          ''                          => 9
      }

    def translate
      result = TRANSLATION[mortgage_type]
      result = result[mi_indicator] if result.is_a? Hash

      result
    end
  end
end
