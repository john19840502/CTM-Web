class ChangeFloatToDecimalBranchCompensationDetails < ActiveRecord::Migration
  def up
    change_column :branch_compensation_details, :branch_revenue, :decimal, precision: 3, scale: 2
    change_column :branch_compensation_details, :lo_traditional_split, :decimal, precision: 3, scale: 2
    change_column :branch_compensation_details, :tiered_split_low, :decimal, precision: 3, scale: 2
    change_column :branch_compensation_details, :tiered_split_high, :decimal, precision: 3, scale: 2
    change_column :branch_compensation_details, :tiered_amount, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :branch_compensation_details, :branch_revenue, :float
    change_column :branch_compensation_details, :lo_traditional_split, :float
    change_column :branch_compensation_details, :tiered_split_low, :float
    change_column :branch_compensation_details, :tiered_split_high, :float
    change_column :branch_compensation_details, :tiered_amount, :float
  end
end
