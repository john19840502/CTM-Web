class AddEmailTrackingFieldsToForcedRegistration < ActiveRecord::Migration
  def up
    add_column :forced_registrations, :sent_intent_to_proceed_notice, :boolean
    add_column :forced_registrations, :sent_forced_registration_warning, :boolean
  end

  def down
    remove_column :forced_registrations, :sent_intent_to_proceed_notice
    remove_column :forced_registrations, :sent_forced_registration_warning
  end
end
