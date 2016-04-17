module Translation
  class Ethnicity
    attr_accessor :ethnicity_type
    def initialize(ethnicity_type)
      @ethnicity_type = ethnicity_type
    end

    TRANSLATION =
        {
            'NotApplicable'                                                         => 4,
            'NotHispanicOrLatino'                                                   => 2,
            'HispanicOrLatino'                                                      => 1,
            'InformationNotProvidedByApplicantInMailInternetOrTelephoneApplication' => 3,
        }

    def translate
      TRANSLATION[ethnicity_type]
    end
  end
end