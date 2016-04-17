class RemoveDataPresentFromMersImport < ActiveRecord::Migration
  def up
    remove_column :mers_imports, :data_present
  end

  def down
    add_column :mers_imports, :data_present, :text
  end
end
