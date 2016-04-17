class AddIndexToMersExceptions < ActiveRecord::Migration
  def change
    unless index_exists?(:mers_exceptions, :mers_reconciliation_report_id)
      add_index :mers_exceptions, :mers_reconciliation_report_id
    end
  end
end
