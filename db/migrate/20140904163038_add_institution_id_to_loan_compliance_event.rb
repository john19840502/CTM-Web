class AddInstitutionIdToLoanComplianceEvent < ActiveRecord::Migration
  def change
    add_column :loan_compliance_events, :institutionid, :string
  end
end
