class AddComparedLoanCountToMersReconciliationReport < ActiveRecord::Migration
  def change
    add_column :mers_reconciliation_reports, :compared_loan_count, :integer
  end
end
