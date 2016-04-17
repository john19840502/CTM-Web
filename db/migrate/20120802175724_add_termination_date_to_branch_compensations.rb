class AddTerminationDateToBranchCompensations < ActiveRecord::Migration
  def change
    add_column :branch_compensations, :termination_date, :date
  end
end
