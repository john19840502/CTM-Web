class AddLoansWithDuplicateMinsToDmiImports < ActiveRecord::Migration
  def change
    add_column :dmi_imports, :loans_with_duplicate_mins, :text
  end
end
