class ChangeActionToActionCodeForLoanComplianceEvent < ActiveRecord::Migration
  def change
    rename_column :loan_compliance_events, :action, :action_code
  end
end
