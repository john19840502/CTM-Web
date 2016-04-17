class AddColumnsToSmdsCompassLoanDetails < ActiveRecord::Migration
  def up
    if Rails.env.development? && !ActiveRecord::Base.connection.column_exists?('smds.SMDSCompassLoanDetails', 'HUD902MIPAmt')
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          ADD HUD902MIPAmt      MONEY,
              HUD902MIRate      DECIMAL(8,4),
              EscrowWaiverType  VARCHAR(20),
              Brw1Employer      VARCHAR(80),
              NbrMonthsReserves MONEY
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP COLUMN HUD902MIPAmt,
                      HUD902MIRate,
                      EscrowWaiverType,
                      Brw1Employer,
                      NbrMonthsReserves
      SQL
    end
  end
end
