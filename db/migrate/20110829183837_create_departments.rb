class CreateDepartments < ActiveRecord::Migration
  def self.up
    create_table :departments do |t|
      t.string      :name
      t.string      :uuid
      t.references  :company
      t.timestamps
    end
    
    add_index :departments, :name
    add_index :departments, :uuid
    add_index :departments, :company_id
  end

  def self.down
    drop_table :departments
  end
end
