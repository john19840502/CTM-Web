class AddLabelToNavigations < ActiveRecord::Migration
  def change
    add_column :navigations, :label, :string
    add_index  :navigations, :label
  end
end
