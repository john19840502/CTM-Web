class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string      :name
      t.string      :uuid
      t.timestamps
    end
    
    add_index :companies, :name
    add_index :companies, :uuid
  end

  def self.down
    drop_table :companies
  end
end
