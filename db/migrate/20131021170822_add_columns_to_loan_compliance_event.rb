class AddColumnsToLoanComplianceEvent < ActiveRecord::Migration
  def change
    add_column :loan_compliance_events, :ma_code, :string
    add_column :loan_compliance_events, :cnty_code, :string
    add_column :loan_compliance_events, :st_code, :string
    add_column :loan_compliance_events, :censu_strct, :string
  end
end
