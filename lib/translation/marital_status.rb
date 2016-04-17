module Translation
  class MaritalStatus
    attr_accessor :marital_status_type

    def initialize(marital_status_type)
      @marital_status_type = marital_status_type
    end

    TRANSLATION =
        {
            'Unknown'   => '',
            'Married'   => 'M',
            'Separated' => 'S',
            'Unmarried' => 'U',
        }

    def translate
      TRANSLATION[marital_status_type]
    end
  end
end