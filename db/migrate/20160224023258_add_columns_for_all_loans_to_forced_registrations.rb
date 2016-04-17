class AddColumnsForAllLoansToForcedRegistrations < ActiveRecord::Migration
  def up
    add_column :forced_registrations, :channel, :string
    add_column :forced_registrations, :product_name, :string
    add_column :forced_registrations, :lo_contact_number, :string
    add_column :forced_registrations, :lo_contact_email, :string
  end

  def down
    remove_column :forced_registrations, :channel
    remove_column :forced_registrations, :product_name
    remove_column :forced_registrations, :lo_contact_number
    remove_column :forced_registrations, :lo_contact_email
  end
end
