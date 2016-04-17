class ChangeAssignedOnInitialDisclosureTracking < ActiveRecord::Migration
  def change
    add_column :initial_disclosure_trackings, :loan_purpose, :string
    change_column :initial_disclosure_trackings, :assigned_on, :datetime
  end
end
