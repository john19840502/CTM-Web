class AddTypeToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :type, :string
    add_index :notes, :type
  end
end
