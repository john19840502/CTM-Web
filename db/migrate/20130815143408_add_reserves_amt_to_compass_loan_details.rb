class AddReservesAmtToCompassLoanDetails < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          ADD NonOccupyingCoBorrowerFlg  varchar(1),
              NbrFinancedProperties      int,
              HPMLFlg                    varchar(1),
              ReservesAmt                money
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP COLUMN NonOccupyingCoBorrowerFlg,
                      NbrFinancedProperties,
                      HPMLFlg,
                      ReservesAmt
      SQL
    end
  end
end
