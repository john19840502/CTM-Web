module Translation
  class PmiCompanyCode
    attr_accessor :mi_company_id, :mortgage_type
    def initialize(options)
      @mi_company_id  = options[:mi_company_id]
      @mortgage_type    = options[:mortgage_type]
    end

    TYPE =
        {
            'FHA'                       => 'FR',
            'FarmersHomeAdministration' => '  ',
            'VA'                        => '  ',
        }

    COMPANY =
        {
            3124 => '01',
            1673 => '06',
            1674 => '12',
            1672 => '13',
            1671 => '33',
            8352 => '43'
        }

    def translate
      TYPE[mortgage_type] || COMPANY[mi_company_id]
    end
  end
end
