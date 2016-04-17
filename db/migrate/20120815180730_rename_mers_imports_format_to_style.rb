class RenameMersImportsFormatToStyle < ActiveRecord::Migration
  def up
    rename_column :mers_imports, :format, :style
  end

  def down
    rename_column :mers_imports, :style, :format
  end
end
