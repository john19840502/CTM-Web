class AddLoanIdToBrokerCompModeler < ActiveRecord::Migration
  def change
    change_table :broker_comp_modelers do |t|
      t.references :loan
    end
  end
end
