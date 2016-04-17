class RemoveForeclosureCompleteFromMersImport < ActiveRecord::Migration
  def up
    remove_column :mers_imports, :foreclosure_complete
  end

  def down
    add_column :mers_imports, :foreclosure_complete, :text
  end
end
