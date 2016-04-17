class CreateLoanValidationFactTypeValues < ActiveRecord::Migration
  def change
    create_table :loan_validation_fact_type_values do |t|
      t.references :loan_validation_flow, index: true
      t.references :loan_validation_fact_type, index: true

      t.timestamps
    end
  end
end
