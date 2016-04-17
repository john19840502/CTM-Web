class AddPaidOffFlagToCompassLoanDetails < ActiveRecord::Migration
  def up
    if Rails.env.development? && !ActiveRecord::Base.connection.column_exists?('smds.SMDSCompassLoanDetails', 'PaidOffFlag')
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          ADD PaidOffFlag VARCHAR(1),
              DMIEscrowAcctBal MONEY,
              CalcUPB MONEY,
              HUDCurtailment MONEY
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP COLUMN PaidOffFlag,
                      DMIEscrowAcctBal,
                      CalcUPB,
                      HUDCurtailment
      SQL
    end
  end
end
