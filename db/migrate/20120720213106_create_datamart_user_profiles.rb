class CreateDatamartUserProfiles < ActiveRecord::Migration
  def change
    create_table :datamart_user_profiles do |t|
      t.integer :datamart_user_id
      t.string :title

      t.timestamps
    end
  end
end
 