module Translation
  class CountryCode
    attr_accessor :country_code
    def initialize(country_code)
      @country_code = country_code
    end

    TRANSLATION =
        {
          'Australia'       => 'AUS',
          'Canada'          => 'CAN',
          'China'           => 'CHN',
          'France'          => 'FRA',
          'Germany'         => 'DEU',
          'Hong Kong'       => 'HKG',
          'India'           => 'IND',
          'Japan'           => 'JPN',
          'Mexico'          => 'MEX',
          'Puerto Rico'     => 'PRI',
          'Spain'           => 'ESP',
          'Switzerland'     => 'CHE',
          'United Kingdom'  => 'GBR',
          'Beijing'         => 'CHN',
          'South Korea'     => 'KOR'
        }

    def translate
      TRANSLATION[country_code]
    end
  end
end