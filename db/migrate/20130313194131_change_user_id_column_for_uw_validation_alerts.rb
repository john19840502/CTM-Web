class ChangeUserIdColumnForUwValidationAlerts < ActiveRecord::Migration
  def change
    remove_index :uw_validation_alerts, [:user_id, :loan_id, :rule_id]
    remove_index :uw_validation_alerts, [:loan_id, :user_id]

    change_column :uw_validation_alerts, :user_id, :string

    add_index :uw_validation_alerts, [:user_id, :loan_id, :rule_id]
    add_index :uw_validation_alerts, [:loan_id, :user_id]
  end
end
