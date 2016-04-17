class AddDmiXrefToDmiImports < ActiveRecord::Migration
  def change
    add_column :dmi_imports, :dmi_xref, :text
  end
end
