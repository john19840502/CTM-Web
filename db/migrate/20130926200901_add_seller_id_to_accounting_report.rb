class AddSellerIdToAccountingReport < ActiveRecord::Migration
  def change
    add_column :accounting_reports, :seller_id, :integer
  end
end
