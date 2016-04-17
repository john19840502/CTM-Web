class AddLoanIdToFundingModeler < ActiveRecord::Migration
  def change
    change_table :funding_modelers do |t|
      t.references :loan
    end
  end
end
