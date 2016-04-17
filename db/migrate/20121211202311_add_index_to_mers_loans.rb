class AddIndexToMersLoans < ActiveRecord::Migration
  def change
    unless index_exists?(:mers_loans, :mers_import_id)
      add_index :mers_loans, :mers_import_id
    end
  end
end
