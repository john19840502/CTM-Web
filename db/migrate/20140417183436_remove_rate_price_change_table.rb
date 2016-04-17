class RemoveRatePriceChangeTable < ActiveRecord::Migration
  def change
    drop_table :rate_price_changes
  end
end
