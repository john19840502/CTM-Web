class RemoveTerminationDateFromBranchCompensationDetails < ActiveRecord::Migration
  def up
    remove_column :branch_compensation_details, :termination_date
  end

  def down
    add_column :branch_compensation_details, :termination_date, :date
  end
end
