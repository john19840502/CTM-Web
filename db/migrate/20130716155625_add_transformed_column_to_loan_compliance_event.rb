class AddTransformedColumnToLoanComplianceEvent < ActiveRecord::Migration
  def change
  	add_column :loan_compliance_events, :transformed, :boolean
  end
end
