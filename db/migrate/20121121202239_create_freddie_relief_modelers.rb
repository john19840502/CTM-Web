class CreateFreddieReliefModelers < ActiveRecord::Migration
  def change
    create_table :freddie_relief_modelers do |t|
      t.string :upb
      t.string :accrued_interest
      t.string :payoff_amount
      t.string :fredd_closing_cost
      t.string :upb_perc
      t.string :step_three
      t.string :max_loan_amount
      t.string :actual_loan_amount
      t.string :max_actual_amount
      t.string :princ_curt
      t.string :actual_amount_princ
      t.string :cash_to_borrower
      t.boolean :fredd_lock

      t.timestamps
    end
  end
end
