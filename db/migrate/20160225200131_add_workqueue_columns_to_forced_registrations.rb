class AddWorkqueueColumnsToForcedRegistrations < ActiveRecord::Migration
  def up
    add_column :forced_registrations, :action, :string
    add_column :forced_registrations, :comment, :string
    add_column :forced_registrations, :assigned_to, :string
  end

  def down
    remove_column :forced_registrations, :action
    remove_column :forced_registrations, :comment
    remove_column :forced_registrations, :assigned_to
  end
end
