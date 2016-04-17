module Translation
  class Gender
    attr_accessor :gender_type
    def initialize(gender_type)
      @gender_type = gender_type
    end

    TRANSLATION =
        {
            'NotApplicable'                 => 'N',
            'InformationNotProvidedUnknown' => 'T',
            'Male'                          => 'M',
            'Female'                        => 'F',
            ''                              => ''
        }

    def translate
      TRANSLATION[gender_type]
    end
  end
end