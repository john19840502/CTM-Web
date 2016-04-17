class RemoveDataPresentFromDmiImport < ActiveRecord::Migration
  def up
    remove_column :dmi_imports, :data_present
  end

  def down
    add_column :dmi_imports, :data_present, :text
  end
end
