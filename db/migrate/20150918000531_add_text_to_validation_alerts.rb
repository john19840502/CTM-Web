class AddTextToValidationAlerts < ActiveRecord::Migration
  def change
    add_column :validation_alerts, :text, :string
  end
end
