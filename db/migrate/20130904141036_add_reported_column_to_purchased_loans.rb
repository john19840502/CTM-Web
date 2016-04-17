class AddReportedColumnToPurchasedLoans < ActiveRecord::Migration
  add_column :purchased_loans, :reported, :boolean
end
