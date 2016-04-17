class CreateLoanValidationFactTypes < ActiveRecord::Migration
  def change
    create_table :loan_validation_fact_types do |t|
      t.string :name

      t.timestamps
    end
    
    add_index :loan_validation_fact_types, :name
  end
end
