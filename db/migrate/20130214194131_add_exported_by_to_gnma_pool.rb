class AddExportedByToGnmaPool < ActiveRecord::Migration
  def change
    add_column :smds_gnma_pools, :exported_by, :string
    add_column :smds_gnma_pools, :exported_at, :datetime
  end
end
