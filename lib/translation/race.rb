module Translation
  class Race
    attr_accessor :race_type
    def initialize(race_type)
      @race_type = race_type
    end

    TRANSLATION =
        {
            'AmericanIndianOrAlaskaNative'         => 1,
            'Asian'                                => 2,
            'BlackOrAfricanAmerican'               => 3,
            'NativeHawaiianOrOtherPacificIslander' => 4,
            'White'                                => 5
        }

    def translate
      TRANSLATION[race_type]
    end
  end
end