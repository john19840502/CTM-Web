class AddApraceAndCapraceToLoanComplianceEvent < ActiveRecord::Migration
  def change
  	add_column :loan_compliance_events, :aprace, :string
  	add_column :loan_compliance_events, :caprace, :string
  end
end
