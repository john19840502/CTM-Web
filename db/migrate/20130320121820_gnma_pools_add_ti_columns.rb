class GnmaPoolsAddTiColumns < ActiveRecord::Migration
 def change
    add_column :smds_gnma_pools, :ti_account_number , :string
    add_column :smds_gnma_pools, :ti_bank_id        , :string
  end
end
