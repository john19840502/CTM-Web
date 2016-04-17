class AddLastUpdatedByToLoanComplianceEvent < ActiveRecord::Migration
  def change
    add_column :loan_compliance_events, :last_updated_by, :string
  end
end
