class AddAvgPrimeOfferRatesTable < ActiveRecord::Migration
  def up
    if Rails.env.development? && !ActiveRecord::Base.connection.tables.include?('AvgPrimeOfferRates')
      execute <<-SQL
        CREATE TABLE smds.AvgPrimeOfferRates (
          ID INTEGER PRIMARY KEY NOT NULL,
          EffectiveDt DATE NULL,
          MtgeType VARCHAR(5) NULL,
          TermInYrs SMALLINT NULL,
          APOR DECIMAL(8,4) NULL )
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        DROP TABLE smds.AvgPrimeOfferRates
      SQL
    end
  end
end
