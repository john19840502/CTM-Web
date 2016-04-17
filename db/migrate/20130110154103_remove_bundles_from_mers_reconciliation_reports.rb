class RemoveBundlesFromMersReconciliationReports < ActiveRecord::Migration
  def up
    remove_column :mers_reconciliation_reports, :bundle_file_name
    remove_column :mers_reconciliation_reports, :bundle_content_type
    remove_column :mers_reconciliation_reports, :bundle_file_size
    remove_column :mers_reconciliation_reports, :bundle_updated_at

    remove_column :mers_reconciliation_reports, :bundle_summary_file_name
    remove_column :mers_reconciliation_reports, :bundle_summary_content_type
    remove_column :mers_reconciliation_reports, :bundle_summary_file_size
    remove_column :mers_reconciliation_reports, :bundle_summary_updated_at

    remove_column :mers_reconciliation_reports, :mers_not_in_dmi_bundle_file_name
    remove_column :mers_reconciliation_reports, :mers_not_in_dmi_bundle_content_type
    remove_column :mers_reconciliation_reports, :mers_not_in_dmi_bundle_file_size
    remove_column :mers_reconciliation_reports, :mers_not_in_dmi_bundle_updated_at

    remove_column :mers_reconciliation_reports, :dmi_not_in_mers_bundle_file_name
    remove_column :mers_reconciliation_reports, :dmi_not_in_mers_bundle_content_type
    remove_column :mers_reconciliation_reports, :dmi_not_in_mers_bundle_file_size
    remove_column :mers_reconciliation_reports, :dmi_not_in_mers_bundle_updated_at

    # This class does not exist any more -- Greg
    #MersReconciliationReport.all.each { |r|
    #  r.update_attributes!(:bundle_reconciliation => nil)
    #}
  end

  def down
    add_column :mers_reconciliation_reports, :bundle_file_name, :string
    add_column :mers_reconciliation_reports, :bundle_content_type, :string
    add_column :mers_reconciliation_reports, :bundle_file_size, :integer
    add_column :mers_reconciliation_reports, :bundle_updated_at, :datetime

    add_column :mers_reconciliation_reports, :bundle_summary_file_name, :string
    add_column :mers_reconciliation_reports, :bundle_summary_content_type, :string
    add_column :mers_reconciliation_reports, :bundle_summary_file_size, :integer
    add_column :mers_reconciliation_reports, :bundle_summary_updated_at, :datetime

    add_column :mers_reconciliation_reports, :mers_not_in_dmi_bundle_file_name, :string
    add_column :mers_reconciliation_reports, :mers_not_in_dmi_bundle_content_type, :string
    add_column :mers_reconciliation_reports, :mers_not_in_dmi_bundle_file_size, :integer
    add_column :mers_reconciliation_reports, :mers_not_in_dmi_bundle_updated_at, :datetime

    add_column :mers_reconciliation_reports, :dmi_not_in_mers_bundle_file_name, :string
    add_column :mers_reconciliation_reports, :dmi_not_in_mers_bundle_content_type, :string
    add_column :mers_reconciliation_reports, :dmi_not_in_mers_bundle_file_size, :integer
    add_column :mers_reconciliation_reports, :dmi_not_in_mers_bundle_updated_at, :datetime

  end
end
