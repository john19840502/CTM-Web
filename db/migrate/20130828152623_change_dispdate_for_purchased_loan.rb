class ChangeDispdateForPurchasedLoan < ActiveRecord::Migration
  def up
    change_column :purchased_loans, :dispdate, :string
  end

  def down
    change_column :purchased_loans, :dispdate, :date
  end
end
