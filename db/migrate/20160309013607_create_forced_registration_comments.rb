class CreateForcedRegistrationComments < ActiveRecord::Migration
  def change
    create_table :forced_registration_comments do |t|
      t.integer           :forced_registration_id
      t.string            :comment
      t.string            :user_action
      t.string            :user_name
      t.timestamps
    end
  end
end
