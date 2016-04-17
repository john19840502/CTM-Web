class AddLockExpirationDateToRatePriceChange < ActiveRecord::Migration
  def change
    add_column :rate_price_changes, :lock_expiration_date,                  :datetime
    add_column :rate_price_changes, :lock_expiration_date_last_modified_on, :datetime
  end
end
