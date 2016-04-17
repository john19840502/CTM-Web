class AddSettlementDateToSmdsPools < ActiveRecord::Migration
  def change
    add_column :smds_pools, :settlement_date, :datetime
  end
end
