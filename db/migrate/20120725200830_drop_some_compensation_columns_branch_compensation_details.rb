class DropSomeCompensationColumnsBranchCompensationDetails < ActiveRecord::Migration
  def change
    remove_column :branch_compensation_details, :bsm_override
    remove_column :branch_compensation_details, :per_loan_processed
    remove_column :branch_compensation_details, :per_loan_branch_processed
  end
end
