class AddAcquiredLoanSourceImportIdToAcquiredLoanSource < ActiveRecord::Migration
  def change
    add_column :acquired_loan_sources, :acquired_loan_source_import_id, :integer
  end
end
