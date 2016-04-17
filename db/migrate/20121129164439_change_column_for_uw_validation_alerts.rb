class ChangeColumnForUwValidationAlerts < ActiveRecord::Migration
  def change
    remove_index :uw_validation_alerts, [:user_id, :loan_id, :rule_id]

    change_column :uw_validation_alerts, :rule_id, :decimal, :precision => 20, :scale => 0

    add_index :uw_validation_alerts, [:user_id, :loan_id, :rule_id]
  end
end
