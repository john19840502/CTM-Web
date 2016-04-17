class ChangeStateTypeForValidatedById < ActiveRecord::Migration
  def up
    change_column :loan_validation_events, :validated_by_id, :string
  end

  def down
    change_column :loan_validation_events, :validated_by_id, :integer
  end
end
