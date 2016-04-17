class AlterColumnErrorMessageOnJobStatuses < ActiveRecord::Migration
  def up
    change_column :job_statuses, :error_message, :text
  end

  def down
    change_column :job_statuses, :error_message, :string
  end
end
