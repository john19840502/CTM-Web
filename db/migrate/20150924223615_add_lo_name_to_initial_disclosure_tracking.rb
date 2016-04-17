class AddLoNameToInitialDisclosureTracking < ActiveRecord::Migration
  def change
    add_column :initial_disclosure_trackings, :lo_name, :string
  end
end
