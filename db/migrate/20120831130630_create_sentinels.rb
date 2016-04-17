class CreateSentinels < ActiveRecord::Migration
  def change
    create_table :sentinels do |t|
      t.references  :watchable, :polymorphic => true
      t.integer     :counter,   :default => 0
      t.timestamps
    end
    
    add_index :sentinels, [:watchable_type, :watchable_id]
  end
end
