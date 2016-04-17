class AddTimestampsToInitialDisclosureTracking < ActiveRecord::Migration
  def up
    add_column :initial_disclosure_trackings, :welcome_email_sent_at, :datetime
    add_timestamps :initial_disclosure_trackings

    InitialDisclosureTracking.where(created_at: nil).update_all(created_at: Time.now, updated_at: Time.now, welcome_email_sent_at: Time.now)
  end

  def down
    remove_column :initial_disclosure_trackings, :welcome_email_sent_at
    remove_timestamps :initial_disclosure_trackings
  end
end
