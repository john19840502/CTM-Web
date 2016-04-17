class RenameColumnsToLoanComplianceEvent < ActiveRecord::Migration
  def change
    rename_column :loan_compliance_events, :ma_code, :macode
    rename_column :loan_compliance_events, :cnty_code, :cntycode
    rename_column :loan_compliance_events, :st_code, :stcode
    rename_column :loan_compliance_events, :censu_strct, :censustrct
  end
end
