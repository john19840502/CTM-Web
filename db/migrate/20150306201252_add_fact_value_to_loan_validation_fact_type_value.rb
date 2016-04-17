class AddFactValueToLoanValidationFactTypeValue < ActiveRecord::Migration
  def change
    add_column :loan_validation_fact_type_values, :fact_value, :string
  end
end
