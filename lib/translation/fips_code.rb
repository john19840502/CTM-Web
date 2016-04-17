module Translation
  class FipsCode
    attr_accessor :fips_code
    def initialize(fips_code)
      @fips_code = fips_code
    end

    TRANSLATION =
        {
          'AL' => 1,
          'AK' => 2,
          'AZ' => 4,
          'AR' => 5,
          'CA' => 6,
          'CO' => 8,
          'CT' => 9,
          'DE' => 10,
          'DC' => 11,
          'FL' => 12,
          'GA' => 13,
          'HI' => 15,
          'ID' => 16,
          'IL' => 17,
          'IN' => 18,
          'IA' => 19,
          'KS' => 20,
          'KY' => 21,
          'LA' => 22,
          'ME' => 23,
          'MD' => 24,
          'MA' => 25,
          'MI' => 26,
          'MN' => 27,
          'MS' => 28,
          'MO' => 29,
          'MT' => 30,
          'NE' => 31,
          'NV' => 32,
          'NH' => 33,
          'NJ' => 34,
          'NM' => 35,
          'NY' => 36,
          'NC' => 37,
          'ND' => 38,
          'OH' => 39,
          'OK' => 40,
          'OR' => 41,
          'PA' => 42,
          'RI' => 44,
          'SC' => 45,
          'SD' => 46,
          'TN' => 47,
          'TX' => 48,
          'UT' => 49,
          'VT' => 50,
          'VA' => 51,
          'WA' => 53,
          'WV' => 54,
          'WI' => 55,
          'WY' => 56,
          'AS' => 60,
          'GU' => 66,
          'MP' => 69,
          'PR' => 72,
          'UM' => 74,
          'VI' => 78
        }

    def translate
      TRANSLATION[fips_code]
    end
  end
end