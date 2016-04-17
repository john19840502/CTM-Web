class CreateSmdsPool < ActiveRecord::Migration
  def change
    create_table :smds_pools do |t|
      t.string   :pool_accrual_rate_structure_type
      t.string   :pool_amortization_type
      t.decimal  :pool_fixed_servicing_fee_percent, precision: 6, scale: 4
      t.boolean  :pool_interest_only_indicator
      t.datetime :pool_issue_date
      t.integer  :pool_scheduled_remittance_payment_day
      t.decimal  :pool_security_issue_date_interest_rate_percent, precision: 6, scale: 4
      t.string   :pool_structure_type
      t.string   :pool_suffix_identifier
      t.datetime :security_trade_book_entry_date
      t.timestamps
    end
  end
end
