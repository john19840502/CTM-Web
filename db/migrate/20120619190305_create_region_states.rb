class CreateRegionStates < ActiveRecord::Migration
  def change
    create_table :region_states do |t|
      t.integer :region_id
      t.integer :state_id
      t.datetime  :effective_date

      t.timestamps
    end

    add_index :region_states, [:region_id, :state_id, :effective_date]
  end
end
