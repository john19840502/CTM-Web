class CreateMersOrgs < ActiveRecord::Migration
  def change
    create_table :mers_orgs do |t|
      t.string      :name
      t.string      :local_alias
      t.integer     :org_id
      t.string      :uuid
      t.timestamps
    end
    
    add_index :mers_orgs, :name
    add_index :mers_orgs, :org_id
    add_index :mers_orgs, :uuid
    add_index :mers_orgs, :local_alias
    
    create_table :loans_mers_orgs, :id => false do |t|
      t.references :mers_org
      t.references :loan
    end
    
    add_index :loans_mers_orgs, [:mers_org_id, :loan_id]
  end
end
