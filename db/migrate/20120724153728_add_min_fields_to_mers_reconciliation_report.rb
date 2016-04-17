class AddMinFieldsToMersReconciliationReport < ActiveRecord::Migration
  def change
    add_column :mers_reconciliation_reports, :dmi_not_in_mers, :text
    add_column :mers_reconciliation_reports, :mers_not_in_dmi, :text
  end
end
