class AddConsentColumnsToMasterLoanDetailsCustomLoanData < ActiveRecord::Migration
  def change
    add_column :master_loan_details_custom_loan_data, :consent_action, :string
    add_column :master_loan_details_custom_loan_data, :consent_complete, :boolean
  end
end
