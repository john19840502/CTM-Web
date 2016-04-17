class AddPeriodToLoanComplianceEventUpload < ActiveRecord::Migration
  def change
    add_column :loan_compliance_event_uploads, :month, :integer
    add_column :loan_compliance_event_uploads, :year, :integer
  end
end
