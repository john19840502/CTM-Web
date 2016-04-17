class AddImportTypeToDmiImport < ActiveRecord::Migration
  def change
    add_column :dmi_imports, :import_type , :string
  end
end
