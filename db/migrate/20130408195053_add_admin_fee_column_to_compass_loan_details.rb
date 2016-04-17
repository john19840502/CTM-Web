class AddAdminFeeColumnToCompassLoanDetails < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          ADD HUD813AdminFee      MONEY
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP COLUMN HUD813AdminFee
      SQL
    end
  end
end
