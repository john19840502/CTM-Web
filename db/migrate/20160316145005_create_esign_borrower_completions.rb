class CreateEsignBorrowerCompletions < ActiveRecord::Migration
  def change
    create_table :esign_borrower_completions do |t|
      t.integer :loan_number
      t.integer :esign_signer_id
    end

    add_index :esign_borrower_completions, :loan_number
    add_index :esign_borrower_completions, :esign_signer_id
  end
end
