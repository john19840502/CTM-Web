class ChangeCompensationColumnsDatamartUserCompensationPlans < ActiveRecord::Migration
  def change
    change_column :datamart_user_compensation_plans, :bsm_override, :decimal, precision: 6, scale: 2
    change_column :datamart_user_compensation_plans, :per_loan_processed, :decimal, precision: 6, scale: 2
    change_column :datamart_user_compensation_plans, :per_loan_branch_processed, :decimal, precision: 6, scale: 2
  end
end
