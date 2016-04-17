class AddInitialDiscFieldsToMasterLoanDetailsCustomLoanData < ActiveRecord::Migration
  def change
    add_column :master_loan_details_custom_loan_data, :disclose_by_cd_at, :datetime
    add_column :master_loan_details_custom_loan_data, :disclose_by_cd_user_uuid, :string
  end
end
