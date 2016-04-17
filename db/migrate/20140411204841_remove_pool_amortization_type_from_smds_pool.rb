class RemovePoolAmortizationTypeFromSmdsPool < ActiveRecord::Migration
  def up
    remove_column :smds_pools, :pool_amortization_type
  end

  def down
    add_column :smds_pools, :pool_amortization_type, :string
  end
end
