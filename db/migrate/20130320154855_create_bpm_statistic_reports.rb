class CreateBpmStatisticReports < ActiveRecord::Migration
  def change
    create_table :bpm_statistic_reports do |t|
      t.string    :user_id
      t.string    :loan_num
      t.string    :product_code
      t.date      :start_date
      t.date      :end_date
      t.string    :underwriter
      t.string    :channel
      t.string    :validation_errors
      t.string    :state
      t.string    :loan_status_at_validation

      t.timestamps
    end
    
    add_index :bpm_statistic_reports, :user_id
  end
end
