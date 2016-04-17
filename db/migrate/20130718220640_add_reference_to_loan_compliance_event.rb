class AddReferenceToLoanComplianceEvent < ActiveRecord::Migration
  def change
    add_column :loan_compliance_events, :loan_compliance_event_upload_id, :integer
  end
end
