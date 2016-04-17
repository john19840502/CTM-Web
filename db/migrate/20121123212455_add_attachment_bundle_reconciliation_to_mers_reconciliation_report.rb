class AddAttachmentBundleReconciliationToMersReconciliationReport < ActiveRecord::Migration
  def self.up
    add_column :mers_reconciliation_reports, :bundle_reconciliation_file_name, :string
    add_column :mers_reconciliation_reports, :bundle_reconciliation_content_type, :string
    add_column :mers_reconciliation_reports, :bundle_reconciliation_file_size, :integer
    add_column :mers_reconciliation_reports, :bundle_reconciliation_updated_at, :datetime
  end

  def self.down
    remove_column :mers_reconciliation_reports, :bundle_reconciliation_file_name
    remove_column :mers_reconciliation_reports, :bundle_reconciliation_content_type
    remove_column :mers_reconciliation_reports, :bundle_reconciliation_file_size
    remove_column :mers_reconciliation_reports, :bundle_reconciliation_updated_at
  end
end
