class CreateRatePriceChanges < ActiveRecord::Migration
  def change
    create_table :rate_price_changes do |t|
      t.string :loan_number
      t.decimal :final_note_rate
      t.decimal :net_price
      t.datetime :note_rate_last_changed_on
      t.datetime :net_price_last_changed_on

      t.timestamps
    end
  end
end
