class AddSortIndexToNavigations < ActiveRecord::Migration
  def change
    add_column :navigations, :sort_index, :integer
  end
end
