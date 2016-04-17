class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.string      :uuid
      t.string      :resource
      t.string      :action
      t.string      :uuid
      # t.references  :role
      t.boolean     :is_active,           :default => false      
      t.timestamps
    end

    add_index :permissions, [:resource, :action]    
    add_index :permissions, :uuid
    # add_index :permissions, :role_id
    add_index :permissions, :is_active    
  end

  def self.down
    drop_table :permissions
  end
end
