class AddTypeToCountyLoanLimit < ActiveRecord::Migration
  def change
    add_column :county_loan_limits, :type, :string
    add_index :county_loan_limits, :type
  end
end
