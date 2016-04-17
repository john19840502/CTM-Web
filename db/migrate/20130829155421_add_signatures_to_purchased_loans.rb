class AddSignaturesToPurchasedLoans < ActiveRecord::Migration
  def change
    add_column :purchased_loans, :original_signature, :string
    add_column :purchased_loans, :current_signature, :string
  end
end
