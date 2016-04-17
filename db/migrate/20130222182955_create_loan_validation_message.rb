class CreateLoanValidationMessage < ActiveRecord::Migration
  def change
    create_table :loan_validation_messages do |t|
      t.string :msg_type, limit: 255
      t.string :msg_text, limit: 1023

      t.timestamps
    end

    add_index :loan_validation_messages, [:msg_type, :msg_text]    
    add_index :loan_validation_messages, :msg_text    
  end
end
