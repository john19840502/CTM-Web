class AddMinStatusToMersLoan < ActiveRecord::Migration
  def change
    add_column :mers_loans, :min_status, :integer
  end
end
