class ChangeAplnnoInLoanComplianceEvent < ActiveRecord::Migration
  def up
    change_column :loan_compliance_events, :aplnno, :string
  end

  def down
    change_column :loan_compliance_events, :aplnno, :integer
  end
end
