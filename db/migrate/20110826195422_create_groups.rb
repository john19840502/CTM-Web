class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string      :name
      t.string      :distinguished_name
      t.string      :uuid
      t.string      :root_path
      t.timestamps
    end
    
    add_index :groups, :distinguished_name
    add_index :groups, :uuid
    add_index :groups, :root_path
    
    create_table :groups_users, :id => false do |t|
      t.references :group
      t.references :user
    end
    
    add_index :groups_users, [:group_id, :user_id]
  end

  def self.down
    drop_table :groups
    drop_table :groups_users
  end
end
