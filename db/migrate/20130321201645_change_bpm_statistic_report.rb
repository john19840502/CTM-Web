class ChangeBpmStatisticReport < ActiveRecord::Migration
  def change
    remove_index :bpm_statistic_reports, :user_id
    rename_column :bpm_statistic_reports, :user_id, :user_uuid
    add_index :bpm_statistic_reports, :user_uuid
  end
end
