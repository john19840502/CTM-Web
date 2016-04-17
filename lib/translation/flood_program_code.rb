module Translation
  class FloodProgramCode
    attr_accessor :flood_status_type
    def initialize(flood_status_type)
      @flood_status_type = flood_status_type
    end

    TRANSLATION =
        {
          'Unknown'          => '',
          'NonParticipating' => 'N',
          'Regular'          => 'R',
          ''                 => ''
        }

    def translate
      TRANSLATION[flood_status_type]
    end
  end
end