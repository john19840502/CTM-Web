class ChangeTincomeTypeOnLoanComplianceEvents < ActiveRecord::Migration
  def up
    change_column :loan_compliance_events, :tincome, :string
  end

  def down
    change_column :loan_compliance_events, :tincome, :integer
  end
end
