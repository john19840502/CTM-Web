class CreateFrankDoddModellers < ActiveRecord::Migration
  def change
    create_table :frank_dodd_modellers do |t|
      t.string :origination_fee
      t.string :admin_fee
      t.string :third_pt_proc_fee
      t.string :appraisal_fee
      t.string :credit_report
      t.string :flood_cert
      t.string :interim_interest
      t.string :hoi_premium
      t.string :escrow
      t.string :taxes_due
      t.string :title_fees
      t.string :owner_policy
      t.string :recording_fees
      t.string :transfer_taxes
      t.string :misc_fees
      t.string :prorated_taxes

      t.timestamps
    end
  end
end
