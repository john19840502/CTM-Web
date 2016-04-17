class AddUltiProEmployeeIdToDatamartUserProfile < ActiveRecord::Migration
  def change
    add_column :datamart_user_profiles, :ultipro_emp_id, :string
  end
end
