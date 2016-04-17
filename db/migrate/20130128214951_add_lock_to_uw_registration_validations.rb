class AddLockToUwRegistrationValidations < ActiveRecord::Migration
  def change
    add_column :uw_registration_validations, :lock, :boolean
  end
end
