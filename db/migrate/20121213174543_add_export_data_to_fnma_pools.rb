class AddExportDataToFnmaPools < ActiveRecord::Migration
  def change
    add_column :smds_pools, :exported_at, :datetime
    add_column :smds_pools, :exported_by, :string
  end
end
