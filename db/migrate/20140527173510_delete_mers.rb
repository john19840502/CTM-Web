class DeleteMers < ActiveRecord::Migration
  def change
    drop_table :acquired_loan_sources
    drop_table :acquired_loan_source_imports
    drop_table :dmi_imports
    drop_table :dmi_loans
    drop_table :dmi_xrefs
    drop_table :dmi_xref_imports
    drop_table :mers_biennial_reviews
    drop_table :mers_exceptions
    drop_table :mers_imports
    drop_table :mers_loans
    drop_table :mers_reconciliation_reports
  end
end
