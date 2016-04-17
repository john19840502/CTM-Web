class AddPrefixToSmdsPool < ActiveRecord::Migration
  def change
    add_column :smds_pools, :prefix, :string
  end
end
