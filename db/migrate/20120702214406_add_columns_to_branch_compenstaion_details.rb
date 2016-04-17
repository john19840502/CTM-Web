class AddColumnsToBranchCompenstaionDetails < ActiveRecord::Migration
  def change
    add_column :branch_compensation_details, :per_loan_processed, :decimal, precision: 3, scale: 2
    add_column :branch_compensation_details, :per_loan_branch_processed, :decimal, precision: 3, scale: 2
  end
end
