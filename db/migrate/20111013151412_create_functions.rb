class CreateFunctions < ActiveRecord::Migration
  def change
    create_table :functions do |t|
      t.string      :uuid
      t.string      :name
      t.boolean     :is_active, :default => true
      t.timestamps
    end
    
    add_index :functions, :name
    add_index :functions, :uuid
    add_index :functions, :is_active
  
    create_table :functions_permissions, :id => false do |t|
      t.references  :function
      t.references  :permission
    end
    
    add_index :functions_permissions, [:function_id, :permission_id]
  
    create_table :functions_roles, :id => false do |t|
      t.references  :function
      t.references  :role
    end
    
    add_index :functions_roles, [:function_id, :role_id]
  
  end
end
