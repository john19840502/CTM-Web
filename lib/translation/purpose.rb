module Translation
  class Purpose
    attr_accessor :purpose_type, :property_usage_type
    def initialize(options)
      @purpose_type       = options[:purpose_type]
      @property_usage_type = options[:property_usage_type]
    end

    CONSTRUCTION_ONLY = {}
    CONSTRUCTION_TO_PERMANENT = {}
    OTHER = {}
    PURCHASE =
        {
          'Investor' => 17,
          'PrimaryResidence'  => 15,
          'SecondHome' => 16
        }

    REFINANCE =
      {
        'Investor' => 27,
        'PrimaryResidence' => 25,
        'SecondHome' => 26
      }

    TRANSLATION =
        {
            'ConstructionOnly'        => CONSTRUCTION_ONLY,
            'ConstructionToPermanent' => CONSTRUCTION_TO_PERMANENT,
            'Other'                   => OTHER,
            'Purchase'                => PURCHASE,
            'Refinance'               => REFINANCE

        }

    def translate
      TRANSLATION[purpose_type][property_usage_type]
    end
  end
end