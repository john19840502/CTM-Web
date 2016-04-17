class CreateFundingModelers < ActiveRecord::Migration
  def change
    create_table :funding_modelers do |t|
      t.string :origination_fee
      t.string :admin_fee
      t.string :discount_fee
      t.string :appraisal_fee
      t.string :mortgage_insurance
      t.string :flood_cert
      t.string :interim_interest
      t.string :escrow
      t.string :loan_amount
      t.string :los_wire
      t.string :wire_amt
      t.string :wire_diff
      t.boolean :fund_lock

      t.timestamps
    end
  end
end
