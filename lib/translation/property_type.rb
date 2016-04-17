module Translation
  class PropertyType
    attr_accessor :gse_property_type

    def initialize gse_property_type
      self.gse_property_type = gse_property_type
    end

    TRANSLATION =
        {
            'DetachedCondominium'           => 16,
            'ManufacturedHomeMultiwide'     => 81,
            'Other'                         => 81,
            'HighRiseCondominium'           => 16,
            'PUD'                           => 15,
            ''                              => '',
            'Detached'                      => 10,
            'ManufacturedHousingSingleWide' => 81,
            'Condominium'                   => 16,
            'Attached'                      => 10,
            'ManufacturedHousing'           => 81,
            'Cooperative'                   => 18
        }

    def translate
      TRANSLATION[gse_property_type]
    end
  end
end