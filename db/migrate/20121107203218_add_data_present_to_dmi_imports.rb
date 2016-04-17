class AddDataPresentToDmiImports < ActiveRecord::Migration
  def change
    add_column :dmi_imports, :data_present, :text
  end
end
