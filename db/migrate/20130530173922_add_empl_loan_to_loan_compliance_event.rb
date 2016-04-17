class AddEmplLoanToLoanComplianceEvent < ActiveRecord::Migration
  def change
    add_column :loan_compliance_events, :employee_loan, :boolean
    add_index :loan_compliance_events, :employee_loan
  end
end
