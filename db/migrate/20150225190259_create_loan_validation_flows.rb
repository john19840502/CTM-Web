class CreateLoanValidationFlows < ActiveRecord::Migration
  def change
    create_table :loan_validation_flows do |t|
      t.string :name
      t.references :loan_validation_event, index: true

      t.timestamps
    end

    add_index :loan_validation_flows, :name
  end
end
