class RenameTilSignatireFromImageOnUwRegistrationValidations < ActiveRecord::Migration
  def change
    rename_column :uw_registration_validations, :til_signatire_date_from_image, :til_signature_date_from_image
  end
end
