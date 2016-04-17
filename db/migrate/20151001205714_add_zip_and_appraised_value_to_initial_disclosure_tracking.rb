class AddZipAndAppraisedValueToInitialDisclosureTracking < ActiveRecord::Migration
  def change
    add_column :initial_disclosure_trackings, :zip, :string
    add_column :initial_disclosure_trackings, :estimated_value, :string
    add_column :initial_disclosure_trackings, :status_updated_at, :datetime
  end
end
