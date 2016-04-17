class AddCommentsAndReportableColumnsToLoanComplianceEvent < ActiveRecord::Migration
  def change
    add_column :loan_compliance_events, :reportable?, :boolean
    add_column :loan_compliance_events, :comments, :text
  end
end
