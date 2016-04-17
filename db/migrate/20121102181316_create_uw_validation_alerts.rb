class CreateUwValidationAlerts < ActiveRecord::Migration
  def change
    create_table :uw_validation_alerts do |t|
      t.integer :user_id
      t.string :loan_id, limit: 50
      t.integer :rule_id

      t.timestamps
    end

    add_index :uw_validation_alerts, [:user_id, :loan_id, :rule_id]
  end
end
