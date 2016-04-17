class CreateDatamartUserCompensationPlans < ActiveRecord::Migration
  def change
    create_table :datamart_user_compensation_plans do |t|
      t.integer :datamart_user_id
      t.integer :branch_compensation_id

      t.timestamps
    end

    add_index :datamart_user_compensation_plans, [:branch_compensation_id, :datamart_user_id]
  end
end
