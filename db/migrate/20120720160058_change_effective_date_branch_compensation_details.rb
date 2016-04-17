class ChangeEffectiveDateBranchCompensationDetails < ActiveRecord::Migration
  def up
    change_column :branch_compensation_details, :effective_date, :date
  end

  def down
    change_column :branch_compensation_details, :effective_date, :datetime
  end
end
