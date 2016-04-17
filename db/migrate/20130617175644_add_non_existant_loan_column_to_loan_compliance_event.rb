class AddNonExistantLoanColumnToLoanComplianceEvent < ActiveRecord::Migration
  def change
    add_column :loan_compliance_events, :non_existant_loan, :boolean
  end
end
