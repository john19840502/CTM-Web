class CreateBranchCompensations < ActiveRecord::Migration
  def change
    create_table :branch_compensations do |t|
      t.integer :institution_id
      t.string :name

      t.timestamps
    end

    add_index :branch_compensations, :institution_id
  end
end
