class FipsCodesByCityStateZip < DatabaseDatamartReadonly

  # If we really need a composite key functionality, just add 'composite_primary_keys' gem
  #self.primary_keys = :city_name, :state_code, :zip_code

  def self.sqlserver_create_view
    <<-eos
      SELECT
        [CityName]      AS  city_name,
        [StateCode]     AS  state_code,
        [ZIPCode]       AS  zip_code,
        [AreaCode]      AS  area_code,
        [CountyFIPS]    AS  county_fips,
        [CountyName]    AS  county_name,
        [Preferred?]    AS  preferred,
        [ZipCodeType]   AS  zip_code_type

      FROM ctm.FIPSCodesByCityStateZip
    eos
  end
end
