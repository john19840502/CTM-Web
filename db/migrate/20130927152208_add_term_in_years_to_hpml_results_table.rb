class AddTermInYearsToHpmlResultsTable < ActiveRecord::Migration
  def change
    add_column :hpml_results, :term_in_years, :string
  end
end
