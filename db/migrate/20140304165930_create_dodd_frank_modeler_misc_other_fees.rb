class CreateDoddFrankModelerMiscOtherFees < ActiveRecord::Migration
  def change
    create_table :dodd_frank_modeler_misc_other_fees do |t|
      t.integer :dodd_frank_modeler_id
      t.string :amount
      t.string :description

      t.timestamps
    end

    add_index :dodd_frank_modeler_misc_other_fees, :dodd_frank_modeler_id
  end
end
