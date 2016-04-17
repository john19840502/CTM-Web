class CreateEsignPackageVersions < ActiveRecord::Migration
  def change
    create_table :esign_package_versions do |t|
      t.integer :version_number
      t.integer :external_package_id
      t.integer :loan_number
      t.string :package_type
      t.string :package_status
      t.string :respa_status
      t.boolean :esign_enabled
      t.timestamp :version_date
      t.timestamp :processed_date
      t.timestamps
    end

    add_index :esign_package_versions, :version_number
    add_index :esign_package_versions, :loan_number
    add_index :esign_package_versions, :external_package_id
    add_index :esign_package_versions, :processed_date
  end
end
