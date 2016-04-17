class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string        :login
      t.string        :uuid
      
      # These are for organizational relationship functionality
      t.integer       :parent_id
      t.integer       :lft
      t.integer       :rgt
      
      t.references    :department
      t.references    :job_title

      
      # LDAP Attributes
      t.string        :distinguished_name
      t.string        :display_name
      t.string        :first_name
      t.string        :middle_name
      t.string        :last_name
      t.string        :email
      t.string        :telephone
      t.boolean       :is_active,         :default => true
      t.datetime      :last_cas_redirect_at

      # TODO - other attributes here from Active Directory
      t.datetime      :last_login_at
      t.timestamps
    end
    
    add_index :users, :login
    add_index :users, :uuid
    add_index :users, :parent_id
    add_index :users, [:lft, :rgt]
    add_index :users, :department_id
    add_index :users, :distinguished_name
    add_index :users, :first_name
    add_index :users, :middle_name
    add_index :users, :last_name
    add_index :users, :is_active
    add_index :users, :last_login_at
  end

  def self.down
    drop_table :users
  end
end
