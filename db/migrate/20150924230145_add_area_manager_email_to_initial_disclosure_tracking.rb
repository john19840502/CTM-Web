class AddAreaManagerEmailToInitialDisclosureTracking < ActiveRecord::Migration
  def change
    add_column :initial_disclosure_trackings, :area_manager_email, :string
  end
end
