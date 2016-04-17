class RenameUwValidationAlerts < ActiveRecord::Migration
  def up
    rename_table :uw_validation_alerts, :validation_alerts
    add_column :validation_alerts, :alert_type, :string

    ValidationAlert.update_all(alert_type: 'underwriter')
  end

  def down
    rename_table :validation_alerts, :uw_validation_alerts
    remove_column :uw_validation_alerts, :alert_type
  end
end
