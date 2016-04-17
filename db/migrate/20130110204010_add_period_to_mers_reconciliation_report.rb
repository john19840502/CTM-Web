class AddPeriodToMersReconciliationReport < ActiveRecord::Migration
  def change
    add_column :mers_reconciliation_reports, :period, :date
  end
end
