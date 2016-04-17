class AddInstitutionIdToDatamartUserProfile < ActiveRecord::Migration
  def change
    add_column :datamart_user_profiles, :institution_id, :integer
  end
end
