class CreateBranchCompensationDetails < ActiveRecord::Migration
  def change
    create_table :branch_compensation_details do |t|
      t.integer :branch_compensation_id
      t.float :branch_revenue
      t.float :lo_traditional_split
      t.float :tiered_split_low
      t.float :tiered_split_high
      t.float :tiered_amount
      t.string :bsm_override
      t.datetime :effective_date

      t.timestamps
    end

    add_index :branch_compensation_details, :branch_compensation_id
  end
end
