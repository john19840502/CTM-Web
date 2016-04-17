class AddLoanIdToFreddieReliefModeler < ActiveRecord::Migration
  def change
    change_table :freddie_relief_modelers do |t|
      t.references :loan
    end
  end
end
