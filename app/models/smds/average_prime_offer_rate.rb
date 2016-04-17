class Smds::AveragePrimeOfferRate < DatabaseDatamart

  def self.sqlserver_create_view
    <<-eos
      SELECT        ID          AS id,
                    EffectiveDt AS effective_date,
                    MtgeType    AS mortgage_type,
                    TermInYrs   AS term_in_years,
                    APOR        AS apor
      FROM          [CTM].[smds].[AvgPrimeOfferRates]
    eos
  end
end