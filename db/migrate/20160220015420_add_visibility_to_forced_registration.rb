class AddVisibilityToForcedRegistration < ActiveRecord::Migration
  def up
    add_column :forced_registrations, :visible, :boolean 
  end

  def down
    remove_column :forced_registrations, :visible
  end
end
