class RemoveTransactionTypeAndLeFundingFeePctFromInitialDisclosureValidation < ActiveRecord::Migration
  def change
    change_table :initial_disclosure_validations do |t|
      t.remove :transaction_type, :le_funding_fee_pct
    end
  end
end
