class ChangeTypeForRatePriceChangesRateAndPrice < ActiveRecord::Migration
  def up
    change_column :rate_price_changes, :final_note_rate, :decimal, :precision => 6, :scale => 4 
    change_column :rate_price_changes, :net_price, :decimal, :precision => 8, :scale => 4
  end

  def down
    change_column :rate_price_changes, :final_note_rate, :integer
    change_column :rate_price_changes, :net_price, :integer
  end
end
