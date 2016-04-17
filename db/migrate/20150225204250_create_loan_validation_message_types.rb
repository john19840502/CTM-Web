class CreateLoanValidationMessageTypes < ActiveRecord::Migration
  def change
    create_table :loan_validation_message_types do |t|
      t.string :name
      t.string :message_type

      t.timestamps
    end
    add_index :loan_validation_message_types, :name
  end
end
