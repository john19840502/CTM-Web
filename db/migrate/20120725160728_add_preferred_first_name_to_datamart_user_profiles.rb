class AddPreferredFirstNameToDatamartUserProfiles < ActiveRecord::Migration
  def change
    add_column :datamart_user_profiles, :preferred_first_name, :string, limit: 50
  end
end
