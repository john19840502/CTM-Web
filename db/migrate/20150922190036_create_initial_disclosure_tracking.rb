class CreateInitialDisclosureTracking < ActiveRecord::Migration
  def change
    create_table :initial_disclosure_trackings do |t|
      t.string :loan_num
      t.string :lo_email
      t.datetime :app_date
      t.datetime :interview_date
      t.string :borrower_last_name
      t.string :product_code
      t.string :property_state
      t.string :lock_status
      t.string :branch_id
      t.string :branch_name
      t.string :area_manager
      t.string :disclosure_requested
      t.string :dup_ssn
      t.string :assign_to
      t.string :assigned_by
      t.string :assigned_on
      t.string :channel
      t.string :wq_loan_status
    end
  end
end
