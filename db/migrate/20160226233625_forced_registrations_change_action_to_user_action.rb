class ForcedRegistrationsChangeActionToUserAction < ActiveRecord::Migration
  def change
    rename_column :forced_registrations, :action, :user_action
  end
end
