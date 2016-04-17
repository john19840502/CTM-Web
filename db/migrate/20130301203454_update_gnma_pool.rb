class UpdateGnmaPool < ActiveRecord::Migration
  def change
    change_column :smds_gnma_pools, :original_aggregate_amount, :decimal, precision: 10, scale: 2    
    change_column :smds_gnma_pools, :security_rate, :decimal, precision: 6, scale: 3    
    change_column :smds_gnma_pools, :low_rate, :decimal, precision: 6, scale: 3    
    change_column :smds_gnma_pools, :high_rate, :decimal, precision: 6, scale: 3    
  end
end