class ChangeFieldTypeOnLoanComplianceEvent < ActiveRecord::Migration
  def change
    change_column :loan_compliance_events, :broker, :string
    change_column :loan_compliance_events, :loanrep, :string
  end
end
