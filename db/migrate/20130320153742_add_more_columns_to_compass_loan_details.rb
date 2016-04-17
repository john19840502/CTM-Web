class AddMoreColumnsToCompassLoanDetails < ActiveRecord::Migration
  def up
    if Rails.env.development? && !ActiveRecord::Base.connection.column_exists?('smds.SMDSCompassLoanDetails', 'FHAMIRenewalRate')
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          ADD FHAMIRenewalRate decimal(8,4),
              HUD902MIPAmt money,
              HUD902MIPRate decimal(8,4),
              EscrowWaiverType varchar(20),
              Brw1Employer varchar(80),
              NbrMonthsReserves money
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP COLUMN FHAMIRenewalRate,
                      HUD902MIPAmt,
                      HUD902MIPRate,
                      EscrowWaiverType,
                      Brw1Employer,
                      NbrMonthsReserves
      SQL
    end
  end
end
