class RenameColumnOnAreaManagerRegions < ActiveRecord::Migration
  def up
    rename_column :area_manager_regions, :area_manager, :datamart_user_id
  end

  def down
    rename_column :area_manager_regions, :datamart_user_id, :area_manager
  end
end
