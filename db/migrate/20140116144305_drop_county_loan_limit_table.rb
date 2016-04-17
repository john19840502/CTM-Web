class DropCountyLoanLimitTable < ActiveRecord::Migration
  def up
    drop_table :county_loan_limits
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
