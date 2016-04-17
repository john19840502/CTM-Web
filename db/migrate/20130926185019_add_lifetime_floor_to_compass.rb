class AddLifetimeFloorToCompass < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
         ADD  LifetimeFloor VARCHAR(10)
      SQL
    end
  end
  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
         DROP_COLUMN LifetimeFloor 
      SQL
    end
  end
end
