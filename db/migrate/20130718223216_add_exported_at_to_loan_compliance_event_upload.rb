class AddExportedAtToLoanComplianceEventUpload < ActiveRecord::Migration
  def change
    add_column :loan_compliance_event_uploads, :exported_at, :datetime
  end
end
