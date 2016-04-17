class AddSignaturesToLoanComplianceEvent < ActiveRecord::Migration
  def change
    add_column :loan_compliance_events, :original_signature, :string
    add_column :loan_compliance_events, :current_signature, :string
  end
end
