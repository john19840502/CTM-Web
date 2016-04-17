class AddGnmaPoolNumberToGnmaPool < ActiveRecord::Migration
  def change
    add_column :smds_gnma_pools, :gnma_pool_number, :string
  end
end
