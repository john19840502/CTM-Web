class CreateLoanValidationEventMessages < ActiveRecord::Migration
  def change
    create_table :loan_validation_event_messages do |t|
      t.references :loan_validation_flow, index: true
      t.references :loan_validation_message_type, index: true

      t.timestamps
    end
  end
end
