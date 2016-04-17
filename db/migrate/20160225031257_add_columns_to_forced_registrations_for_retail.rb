class AddColumnsToForcedRegistrationsForRetail < ActiveRecord::Migration
  def up
    add_column :forced_registrations, :branch, :string
  end

  def down
    remove_column :forced_registrations, :branch
  end
end
