class AddSomeCompensationColumnsToDatamartUserCompensationPlans < ActiveRecord::Migration
  def change
    add_column :datamart_user_compensation_plans, :bsm_override, :decimal, precision: 6, scale: 2
    add_column :datamart_user_compensation_plans, :per_loan_processed, :decimal, precision: 6, scale: 2
    add_column :datamart_user_compensation_plans, :per_loan_branch_processed, :decimal, precision: 6, scale: 2
  end
end
