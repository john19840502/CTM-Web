class AddColumnsToForcedRegistrationsForWholesale < ActiveRecord::Migration
  def up
    add_column :forced_registrations, :area_manager, :string
    add_column :forced_registrations, :institution, :string
    add_column :forced_registrations, :state, :string
  end

  def down
    remove_column :forced_registrations, :area_manager
    remove_column :forced_registrations, :institution
    remove_column :forced_registrations, :state
  end
end
