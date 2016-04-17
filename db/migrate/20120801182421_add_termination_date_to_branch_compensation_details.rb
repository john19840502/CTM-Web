class AddTerminationDateToBranchCompensationDetails < ActiveRecord::Migration
  def change
    add_column :branch_compensation_details, :termination_date, :date
  end
end
