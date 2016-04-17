class RemoveAccountNumbersFromGnmaFile < ActiveRecord::Migration
  def up
    remove_column :smds_gnma_pools, :pi_account_number
    remove_column :smds_gnma_pools, :ti_account_number
  end

  def down
    add_column :smds_gnma_pools, :pi_account_number, :string
    add_column :smds_gnma_pools, :ti_account_number, :string
  end
end
