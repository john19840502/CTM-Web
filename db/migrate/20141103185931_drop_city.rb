class DropCity < ActiveRecord::Migration
  def up
    drop_table :cities
  end
end
