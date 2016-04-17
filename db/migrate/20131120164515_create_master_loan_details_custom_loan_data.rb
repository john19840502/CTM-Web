class CreateMasterLoanDetailsCustomLoanData < ActiveRecord::Migration
  def change
    create_table :master_loan_details_custom_loan_data do |t|
      t.string  :loan_num
      t.boolean :force_boarding, default: false
    end
  end
end
