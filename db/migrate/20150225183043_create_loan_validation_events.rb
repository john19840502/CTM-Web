class CreateLoanValidationEvents < ActiveRecord::Migration
  def change
    create_table :loan_validation_events do |t|
      t.string :validated_by
      t.integer :validated_by_id
      t.string :validation_type
      t.string :loan_num
      t.string :underwriter
      t.string :product_code
      t.string :channel
      t.string :property_state
      t.string :loan_status
      t.string :pipeline_status

      t.timestamps
    end

    add_index :loan_validation_events, :underwriter
    add_index :loan_validation_events, :channel
    add_index :loan_validation_events, :loan_num
    add_index :loan_validation_events, :validated_by_id
    add_index :loan_validation_events, :validated_by
    add_index :loan_validation_events, :validation_type
  end
end
