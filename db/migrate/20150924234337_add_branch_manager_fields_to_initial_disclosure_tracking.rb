class AddBranchManagerFieldsToInitialDisclosureTracking < ActiveRecord::Migration
  def change
    add_column :initial_disclosure_trackings, :branch_manager, :string
    add_column :initial_disclosure_trackings, :branch_manager_email, :string
  end
end
