class AddJobStatusToLoanComplianceEventUploads < ActiveRecord::Migration
  def change
    add_column :loan_compliance_event_uploads, :job_status_id, :integer

    add_index :loan_compliance_event_uploads, :job_status_id
  end
end
