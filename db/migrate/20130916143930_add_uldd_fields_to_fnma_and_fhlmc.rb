class AddUlddFieldsToFnmaAndFhlmc < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
         ADD  FloorRatePercent VARCHAR(10),
              FirstMaximumRateChangePercent VARCHAR(10),
              SubsequentMaximumRateChangePercent VARCHAR(10),
              FirstRateAdjustmentMonths VARCHAR(10),
              SubsequentRateAdjustmentMonths VARCHAR(10)
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP_COLUMN FloorRatePercent,
                      FirstMaximumRateChangePercent,
                      SubsequentMaximumRateChangePercent
                      FirstRateAdjustmentMonths,
                      SubsequentRateAdjustmentMonths
      SQL
    end
  end
end
