class AddCalcAggregateLoanCurtailmentsToSmdsCompassLoanDetails < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          ADD CalcAggregateLoanCurtailments MONEY,
              CalcSoldScheduledBal MONEY
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP COLUMN CalcAggregateLoanCurtailments,
                      CalcSoldScheduledBal
      SQL
    end
  end
end
