class CreateAreaManagerRegions < ActiveRecord::Migration
  def change
    create_table :area_manager_regions do |t|
      t.integer    :region_id
      t.string     :area_manager
      t.timestamps
    end
    
    add_index :area_manager_regions, [:area_manager, :region_id]
  end
end
