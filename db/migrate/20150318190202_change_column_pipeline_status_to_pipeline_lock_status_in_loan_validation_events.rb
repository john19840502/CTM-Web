class ChangeColumnPipelineStatusToPipelineLockStatusInLoanValidationEvents < ActiveRecord::Migration
  def up
    rename_column :loan_validation_events, :pipeline_status, :pipeline_lock_status
  end

  def down
    rename_column :loan_validation_events, :pipeline_lock_status, :pipeline_status
  end
end
