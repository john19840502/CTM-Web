class AddGinnieFieldsToCompassLoanDetails < ActiveRecord::Migration
  def up
    if Rails.env.development? && !ActiveRecord::Base.connection.column_exists?('smds.SMDSCompassLoanDetails', 'FHAMIRenewalRate')
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          ADD FHAMIRenewalRate DECIMAL(8,4)
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP COLUMN FHAMIRenewalRate
      SQL
    end
  end
end
