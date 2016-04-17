class CreateHpmlResults < ActiveRecord::Migration
  def change
    create_table :hpml_results do |t|
      t.string :loan_number
      t.string :apor
      t.string :apr
      t.string :hpml
      t.string :rate_spread
      t.string :lock_escrow_waiver
      t.string :escrow_waiver_1003
      t.string :loan_status
      t.string :rate_set_date
      t.string :loan_term
      t.string :product_type
      t.string :amortization_type
      t.string :user_id
      t.string :date_performed

      t.timestamps
    end
  end
end
