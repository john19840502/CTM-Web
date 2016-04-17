class AddEffectiveDateToDatamartUserCompensationPlans < ActiveRecord::Migration
  def change
    add_column :datamart_user_compensation_plans, :effective_date, :datetime
  end
end
