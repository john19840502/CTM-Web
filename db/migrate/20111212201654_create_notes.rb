class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.text       :body
      t.integer    :position
      t.references :noteable, :polymorphic => true
      t.boolean    :is_response_needed,                     :default => false
      t.boolean    :is_resolved,                            :default => true
      t.string     :entry_method,                           :default => 'system'
      t.integer    :parent_id
      t.integer    :lft
      t.integer    :rgt
      t.string     :uuid
      t.timestamps
    end
    
    add_index :notes, :position
    add_index :notes, [:noteable_type, :noteable_id]
    add_index :notes, :is_response_needed
    add_index :notes, :is_resolved
    add_index :notes, :entry_method
    add_index :notes, [:parent_id, :lft, :rgt]
    add_index :notes, :uuid
    
  end
end
