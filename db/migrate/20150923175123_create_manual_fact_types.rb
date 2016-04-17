class CreateManualFactTypes < ActiveRecord::Migration
  def change
    create_table :manual_fact_types do |t|
      t.integer :loan_num
      t.string  :name
      t.string  :value

      t.timestamps
    end
  end
end
