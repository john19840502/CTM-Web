
module Translation
  class StateCode
    attr_accessor :state_abbreviation

    def initialize(abbreviation)
      self.state_abbreviation = abbreviation
    end

    def translate
      Fiserv::StateCodes.translate state_abbreviation
    end
  end
end
