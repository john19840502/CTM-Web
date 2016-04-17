class AddFieldsToInitialDisclosureTracking < ActiveRecord::Migration
  def change
    add_column :initial_disclosure_trackings, :pipeline_loan_status, :string
    add_column :initial_disclosure_trackings, :visible, :boolean, default: true

    add_index :initial_disclosure_trackings, [:loan_num, :visible, :channel]
    add_index :initial_disclosure_trackings, :visible
  end
end
