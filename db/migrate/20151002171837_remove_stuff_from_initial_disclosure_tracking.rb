class RemoveStuffFromInitialDisclosureTracking < ActiveRecord::Migration
  def change
    remove_column :initial_disclosure_trackings, :lo_email, :string
    remove_column :initial_disclosure_trackings, :lo_name, :string
    remove_column :initial_disclosure_trackings, :app_date, :datetime
    remove_column :initial_disclosure_trackings, :interview_date, :datetime
    remove_column :initial_disclosure_trackings, :borrower_last_name, :string
    remove_column :initial_disclosure_trackings, :product_code, :string
    remove_column :initial_disclosure_trackings, :property_state, :string
    remove_column :initial_disclosure_trackings, :lock_status, :string
    remove_column :initial_disclosure_trackings, :branch_id, :string
    remove_column :initial_disclosure_trackings, :branch_name, :string
    remove_column :initial_disclosure_trackings, :area_manager, :string
    remove_column :initial_disclosure_trackings, :disclosure_requested, :string
    remove_column :initial_disclosure_trackings, :dup_ssn, :string
    remove_column :initial_disclosure_trackings, :area_manager_email, :string
    remove_column :initial_disclosure_trackings, :branch_manager, :string
    remove_column :initial_disclosure_trackings, :branch_manager_email, :string
    remove_column :initial_disclosure_trackings, :loan_purpose, :string
    remove_column :initial_disclosure_trackings, :zip, :string
    remove_column :initial_disclosure_trackings, :estimated_value, :string
    remove_column :initial_disclosure_trackings, :channel, :string
    remove_column :initial_disclosure_trackings, :pipeline_loan_status, :string
  end
end
