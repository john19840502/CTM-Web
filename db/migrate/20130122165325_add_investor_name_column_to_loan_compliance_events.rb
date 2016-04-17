class AddInvestorNameColumnToLoanComplianceEvents < ActiveRecord::Migration
  def change
    add_column :loan_compliance_events, :investor_name, :string
  end
end
