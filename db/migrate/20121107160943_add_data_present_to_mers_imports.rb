class AddDataPresentToMersImports < ActiveRecord::Migration
  def change
    add_column :mers_imports, :data_present, :text
  end
end
