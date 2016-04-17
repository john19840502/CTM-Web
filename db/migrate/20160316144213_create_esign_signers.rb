class CreateEsignSigners < ActiveRecord::Migration
  def change
    create_table :esign_signers do |t|
      t.integer :loan_number
      t.string :external_signer_id
      t.string :email
      t.string :full_name
      t.string :first_name
      t.string :last_name
      t.timestamp :consent_date
      t.timestamp :start_date
      t.timestamp :completed_date
    end

    add_index :esign_signers, :external_signer_id
  end
end
