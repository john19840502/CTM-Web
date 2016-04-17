class ChangePercentageFieldsInBranchCompensationDetails < ActiveRecord::Migration
  def change
    change_column :branch_compensation_details, :branch_revenue, :decimal, precision: 5, scale: 3
    change_column :branch_compensation_details, :lo_traditional_split, :decimal, precision: 5, scale: 3
    change_column :branch_compensation_details, :tiered_split_low, :decimal, precision: 5, scale: 3
    change_column :branch_compensation_details, :tiered_split_high, :decimal, precision: 5, scale: 3
  end
end
