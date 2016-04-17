class CreateLoanComplianceEventUpload < ActiveRecord::Migration
  def up
    create_table :loan_compliance_event_uploads do |t|
      t.string    :user_uuid
      t.string    :hmda_loans_file_name
      t.string    :hmda_loans_content_type
      t.integer   :hmda_loans_file_size
      t.datetime  :hmda_loans_updated_at

      t.timestamps
    end    

    add_index :loan_compliance_event_uploads, :user_uuid
  end

  def down
    drop_table :loan_compliance_event_uploads
  end
end
