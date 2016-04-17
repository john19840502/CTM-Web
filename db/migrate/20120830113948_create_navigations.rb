class CreateNavigations < ActiveRecord::Migration
  def change
    create_table :navigations do |t|
      t.string      :key
      t.string      :name
      t.string      :path
      t.text        :options
      t.integer     :parent_id
      # t.integer     :lft
      # t.integer     :rgt
      # t.integer     :depth
      t.integer     :position
      
      t.references  :subdomain
      t.timestamps
    end
    
    add_index :navigations, :key
    add_index :navigations, :name
    add_index :navigations, :parent_id
    add_index :navigations, :path
    # add_index :navigations, [:lft, :rgt]
    # add_index :navigations, :depth
    add_index :navigations, :position
  end
end
