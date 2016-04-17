class AddReasonAndActionToValidationAlert < ActiveRecord::Migration
  def change
    add_column :validation_alerts, :reason, :string
    add_column :validation_alerts, :action, :string
  end
end
