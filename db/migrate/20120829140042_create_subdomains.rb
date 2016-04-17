class CreateSubdomains < ActiveRecord::Migration
  def change
    create_table :subdomains do |t|
      t.string      :uuid
      t.string      :name
      t.string      :label
      t.string      :href
      t.timestamps
    end
    
    add_index :subdomains, :name
    
    create_table :groups_subdomains, :id => false do |t|
      t.references  :group
      t.references  :subdomain
    end
    
    add_index :groups_subdomains, [:group_id, :subdomain_id]
  end
end
