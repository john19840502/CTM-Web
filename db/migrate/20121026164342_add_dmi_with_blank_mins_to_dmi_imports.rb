class AddDmiWithBlankMinsToDmiImports < ActiveRecord::Migration
  def change
    add_column :dmi_imports, :dmi_with_blank_mins, :text
  end
end
