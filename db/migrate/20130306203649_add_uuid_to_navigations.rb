class AddUuidToNavigations < ActiveRecord::Migration
  def change
    add_column :navigations, :uuid, :string
    add_index :navigations, :uuid
  end
end
