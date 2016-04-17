class AddReconciledHistoryColumnsToLoanComplianceEvent < ActiveRecord::Migration
  def change
    add_column :loan_compliance_events, :exception_history, :string
    add_column :loan_compliance_events, :reconciled_by, :string
    add_column :loan_compliance_events, :reconciled_at, :string
  end
end
