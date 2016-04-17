class AddBmsfOverrideToBranchEmployeeOtherCompensation < ActiveRecord::Migration
  def change
    add_column :branch_employee_other_compensations, :bmsf_override, :decimal
  end
end
