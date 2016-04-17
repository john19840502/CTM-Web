class AddJobStatusToAccountingReport < ActiveRecord::Migration
  def change
    add_column :accounting_reports, :job_status_id, :integer
  end
end
