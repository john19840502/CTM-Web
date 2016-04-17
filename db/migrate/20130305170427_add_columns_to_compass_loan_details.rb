class AddColumnsToCompassLoanDetails < ActiveRecord::Migration
  def up
    if Rails.env.development? && !ActiveRecord::Base.connection.column_exists?('smds.SMDSCompassLoanDetails', 'GiftAmt')
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          ADD GiftAmt MONEY,
              GiftFlg VARCHAR(1),
              MIPmtAmt MONEY
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP COLUMN GiftAmt,
                      GiftFlg,
                      MIPmtAmt
      SQL
    end
  end
end
