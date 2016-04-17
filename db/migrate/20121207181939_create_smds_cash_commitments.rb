class CreateSmdsCashCommitments < ActiveRecord::Migration
  def change
    create_table :smds_cash_commitments do |t|
      t.datetime :certified_on
      t.datetime :exported_at
      t.string   :exported_by
      t.string   :investor_commitment_number
      t.datetime :settlement_date
      t.timestamps
    end
  end
end
