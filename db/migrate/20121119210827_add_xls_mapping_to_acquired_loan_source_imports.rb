class AddXlsMappingToAcquiredLoanSourceImports < ActiveRecord::Migration
  def change
    add_column :acquired_loan_source_imports, :xls_mapping, :text
  end
end
