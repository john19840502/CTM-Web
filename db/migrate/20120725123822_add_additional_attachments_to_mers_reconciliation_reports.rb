class AddAdditionalAttachmentsToMersReconciliationReports < ActiveRecord::Migration
  def change
    
    add_column :mers_reconciliation_reports, :mers_not_in_dmi_bundle_file_name,     :string
    add_column :mers_reconciliation_reports, :mers_not_in_dmi_bundle_content_type,  :string
    add_column :mers_reconciliation_reports, :mers_not_in_dmi_bundle_file_size,     :integer
    add_column :mers_reconciliation_reports, :mers_not_in_dmi_bundle_updated_at,    :datetime
    add_column :mers_reconciliation_reports, :mers_not_in_dmi_bundle_fingerprint,   :string
    
    add_column :mers_reconciliation_reports, :dmi_not_in_mers_bundle_file_name,     :string
    add_column :mers_reconciliation_reports, :dmi_not_in_mers_bundle_content_type,  :string
    add_column :mers_reconciliation_reports, :dmi_not_in_mers_bundle_file_size,     :integer
    add_column :mers_reconciliation_reports, :dmi_not_in_mers_bundle_updated_at,    :datetime
    add_column :mers_reconciliation_reports, :dmi_not_in_mers_bundle_fingerprint,   :string

  end
end
