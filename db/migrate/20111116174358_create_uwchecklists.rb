class CreateUwchecklists < ActiveRecord::Migration
  def change
    create_table :uwchecklist_sections do |t|
      t.string      :name
      t.text        :body
      t.integer     :page
      t.integer     :column
      t.integer     :position
      t.string      :state_display_conditions
      t.string      :loan_program_display_conditions
      t.string      :loan_purpose_display_conditions
      t.boolean     :is_display_for_all_loans, :default => false
      t.boolean     :is_active, :default => true
      t.timestamps
    end
    
    add_index :uwchecklist_sections, :name
    add_index :uwchecklist_sections, :position
    add_index :uwchecklist_sections, :is_active
    
    create_table :uwchecklist_items do |t|
      t.text        :value
      t.string      :bullet_type
      t.integer     :position
      t.string      :state_display_conditions
      t.string      :loan_program_display_conditions
      t.string      :loan_purpose_display_conditions
      t.boolean     :is_active, :default => true
      t.references  :uwchecklist_section
      t.timestamps
    end
    
    add_index :uwchecklist_items, :bullet_type
    add_index :uwchecklist_items, :position
    add_index :uwchecklist_items, :is_active
    add_index :uwchecklist_items, :uwchecklist_section_id
    
  end
end
