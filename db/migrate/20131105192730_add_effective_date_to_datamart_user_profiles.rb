class AddEffectiveDateToDatamartUserProfiles < ActiveRecord::Migration
  def change
    add_column :datamart_user_profiles, :effective_date, :date
    add_index :datamart_user_profiles, :effective_date
  end
end
