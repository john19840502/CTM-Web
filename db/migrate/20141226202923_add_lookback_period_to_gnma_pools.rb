class AddLookbackPeriodToGnmaPools < ActiveRecord::Migration
  def change
    add_column :smds_gnma_pools, :lookback_period, :integer
  end
end
