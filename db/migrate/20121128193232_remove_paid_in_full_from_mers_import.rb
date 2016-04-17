class RemovePaidInFullFromMersImport < ActiveRecord::Migration
  def up
    remove_column :mers_imports, :paid_in_full
  end

  def down
    add_column :mers_imports, :paid_in_full, :text
  end
end
