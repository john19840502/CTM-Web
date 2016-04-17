class ChangeSizeOfValidationAlertsText < ActiveRecord::Migration
  def change
    change_column :validation_alerts, :text, :string, limit: 500
  end
end
