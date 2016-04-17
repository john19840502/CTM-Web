class RenameReportableColumnForLoanComplianceEvent < ActiveRecord::Migration
  def change
    rename_column :loan_compliance_events, :reportable?, :reportable
  end
end
