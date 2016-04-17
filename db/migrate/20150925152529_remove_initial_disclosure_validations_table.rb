class RemoveInitialDisclosureValidationsTable < ActiveRecord::Migration
  def up
    drop_table :initial_disclosure_validations
  end

  def down
    create_table :initial_disclosure_validations do |t|
      t.integer :loan_num
      t.string :use_type
      t.string :veteran_type
      t.string :use_existing_survey
      t.string :user_login
      t.timestamps
    end
  end
end
