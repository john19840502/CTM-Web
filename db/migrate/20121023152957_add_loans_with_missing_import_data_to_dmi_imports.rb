class AddLoansWithMissingImportDataToDmiImports < ActiveRecord::Migration
  def change
    add_column :dmi_imports, :loans_with_missing_import_data, :text
  end
end
