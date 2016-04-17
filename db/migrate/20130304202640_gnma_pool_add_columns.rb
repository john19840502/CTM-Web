class GnmaPoolAddColumns < ActiveRecord::Migration
  def change
    add_column :smds_gnma_pools, :position          , :decimal, precision: 10, scale: 2
    add_column :smds_gnma_pools, :frb_description_1 , :string
    add_column :smds_gnma_pools, :aba_number        , :string
    add_column :smds_gnma_pools, :deliver_to        , :string
    add_column :smds_gnma_pools, :frb_description_2 , :string
  end
end
