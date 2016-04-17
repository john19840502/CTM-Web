class RemoveHpmlResultsTable < ActiveRecord::Migration
  def change
    drop_table :hpml_results
  end
end
