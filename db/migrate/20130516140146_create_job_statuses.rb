class CreateJobStatuses < ActiveRecord::Migration
  def change
    create_table :job_statuses do |t|
      t.string :status
      t.integer :progress
      t.string :error_message

      t.timestamps
    end
  end
end
