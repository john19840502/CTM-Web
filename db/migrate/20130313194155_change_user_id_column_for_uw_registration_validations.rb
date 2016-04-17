class ChangeUserIdColumnForUwRegistrationValidations < ActiveRecord::Migration
  def change
    change_column :uw_registration_validations, :user_id, :string

    add_index :uw_registration_validations, [:loan_id, :user_id]
  end
end
