class CreateAcquiredLoanSources < ActiveRecord::Migration
  def change
    create_table :acquired_loan_sources do |t|
      t.string :lender_num
      t.string :min_num
      t.date :aging_date
      t.string :investor_name

      t.timestamps
    end
  end
end
