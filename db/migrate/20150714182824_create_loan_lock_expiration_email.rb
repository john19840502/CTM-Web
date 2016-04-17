class CreateLoanLockExpirationEmail < ActiveRecord::Migration
  def change
    create_table :loan_lock_expiration_emails do |t|
      t.integer :check_days
      t.text    :loans

      t.timestamps
    end
  end
end
