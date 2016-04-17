class CreateUwRegistrationValidation < ActiveRecord::Migration
  def change
    create_table :uw_registration_validations do |t|
      t.integer :user_id
      t.string :loan_id, limit: 50
      t.date :signature_1003_date 
      t.date :most_recent_imaged_gfe_date 
      t.date :initial_imaged_ctm_gfe_date
      t.date :til_signatire_date_from_image
      t.decimal :prior_apr, precision: 8, scale: 3

      t.timestamps
    end

    add_index :uw_validation_alerts, [:loan_id, :user_id]
  end
end
