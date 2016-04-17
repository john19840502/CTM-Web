class ChangeEffectiveDateDatamartUserCompensationPlans < ActiveRecord::Migration
  def up
    change_column :datamart_user_compensation_plans, :effective_date, :date
  end

  def down
    change_column :datamart_user_compensation_plans, :effective_date, :datetime
  end
end
