class DropCompensationColumnsBranchCompensationDetails < ActiveRecord::Migration
  def change
    remove_column :datamart_user_compensation_plans, :bsm_override
    remove_column :datamart_user_compensation_plans, :per_loan_processed
    remove_column :datamart_user_compensation_plans, :per_loan_branch_processed
  end
end
