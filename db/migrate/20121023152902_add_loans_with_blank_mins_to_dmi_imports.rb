class AddLoansWithBlankMinsToDmiImports < ActiveRecord::Migration
  def change
    add_column :dmi_imports, :loans_with_blank_mins, :text
  end
end
