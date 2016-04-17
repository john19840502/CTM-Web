class CreateAccountingReports < ActiveRecord::Migration
  def change
    create_table :accounting_reports do |t|
      t.string      :name
      t.string      :type
      t.date        :start_date
      t.date        :end_date
      t.string      :status, :default => 'created'  # For state machine
      t.string      :bundle_file_name
      t.string      :bundle_content_type
      t.integer     :bundle_file_size
      t.datetime    :bundle_updated_at
      t.string      :bundle_fingerprint
      t.string      :uuid
      t.timestamps
    end
    
    add_index :accounting_reports, :name
    add_index :accounting_reports, :type
    add_index :accounting_reports, :status
    add_index :accounting_reports, [:start_date, :end_date]
    add_index :accounting_reports, :uuid
    add_index :accounting_reports, :bundle_file_name
    add_index :accounting_reports, :bundle_updated_at
  end
end
