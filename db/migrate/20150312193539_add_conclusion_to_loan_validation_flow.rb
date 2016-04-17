class AddConclusionToLoanValidationFlow < ActiveRecord::Migration
  def up
    add_column :loan_validation_flows, :conclusion, :string
  end

  def down
    remove_column :loan_validation_flows, :conclusion, :string
  end
end
