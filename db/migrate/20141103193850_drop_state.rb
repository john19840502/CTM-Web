class DropState < ActiveRecord::Migration
  def up
    drop_table :states
  end
end
