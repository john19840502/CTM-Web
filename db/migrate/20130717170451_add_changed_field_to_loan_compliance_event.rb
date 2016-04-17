class AddChangedFieldToLoanComplianceEvent < ActiveRecord::Migration
  def change
  	add_column :loan_compliance_events, :changed_values, :string
  end
end
