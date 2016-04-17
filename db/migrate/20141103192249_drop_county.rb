class DropCounty < ActiveRecord::Migration
  def up
    drop_table :counties
  end
end
