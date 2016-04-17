class CreateLoanComplianceEventUploadMonths < ActiveRecord::Migration
  def change
    create_table :loan_compliance_event_upload_periods do |t|
      t.integer :month
      t.integer :year

      t.references :loan_compliance_event_upload
      t.timestamps
    end
  end
end
