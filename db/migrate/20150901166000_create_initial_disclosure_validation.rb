class CreateInitialDisclosureValidation < ActiveRecord::Migration
  def change
    create_table :initial_disclosure_validations do |t|
      t.integer :loan_num
      t.string :transaction_type
      t.string :use_type
      t.string :veteran_type
      t.decimal :le_funding_fee_pct, precision: 5, scale: 2
      t.string :user_login
      t.timestamps
    end
  end
end
