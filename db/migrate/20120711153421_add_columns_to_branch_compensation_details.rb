class AddColumnsToBranchCompensationDetails < ActiveRecord::Migration
  def change
    add_column :branch_compensation_details, :branch_min, :decimal, precision: 6, scale: 2
    add_column :branch_compensation_details, :branch_max, :decimal, precision: 6, scale: 2
    add_column :branch_compensation_details, :lo_min, :decimal, precision: 6, scale: 2
    add_column :branch_compensation_details, :lo_max, :decimal, precision: 6, scale: 2
  end
end