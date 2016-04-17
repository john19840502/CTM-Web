class CreateGnmaPool < ActiveRecord::Migration
  def change
    create_table :smds_gnma_pools do |t|
      t.string   :pool_number
      t.string   :issue_type 
      t.string   :pool_type 
      t.string   :issuer_id 
      t.string   :custodian_id 
      t.datetime :issue_date
      t.datetime :settlement_date
      t.decimal  :original_aggregate_amount
      t.decimal  :security_rate
      t.decimal  :low_rate
      t.decimal  :high_rate
      t.string   :method
      t.datetime :payment_date
      t.datetime :maturity_date
      t.datetime :unpaid_date
      t.integer  :term
      t.integer  :tax_id
      t.integer  :number_of_loans
      t.decimal  :security_rate_margin
      t.datetime :security_change_date
      t.string   :arm_index_type
      t.string   :bond_finance
      t.integer  :certification_and_agreement
      t.integer  :sent_11711
      t.string   :new_issuer
      t.string   :subservicer
      t.string   :pi_account_number
      t.string   :pi_bank_id
      t.timestamps
    end
  end
end
