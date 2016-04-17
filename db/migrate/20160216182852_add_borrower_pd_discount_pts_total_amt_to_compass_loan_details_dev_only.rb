class AddBorrowerPdDiscountPtsTotalAmtToCompassLoanDetailsDevOnly < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          ADD BorrowerPdDiscPtsTotalAmt money
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP COLUMN BorrowerPdDiscPtsTotalAmt
      SQL
    end
  end
end
