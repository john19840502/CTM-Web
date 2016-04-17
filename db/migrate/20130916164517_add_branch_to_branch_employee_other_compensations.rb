class AddBranchToBranchEmployeeOtherCompensations < ActiveRecord::Migration
  def change
    add_column :branch_employee_other_compensations, :institution_id, :integer
    add_index :branch_employee_other_compensations, :institution_id
  end
end
