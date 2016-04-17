class CreateRedwoodExports < ActiveRecord::Migration
  def change
    create_table :redwood_exports do |t|
      t.string      :name
      t.string      :status, :default => 'created'  # For state machine
      t.string      :xml_file_name
      t.string      :xml_content_type
      t.integer     :xml_file_size
      t.datetime    :xml_updated_at
      t.string      :xml_fingerprint
      t.string      :uuid
      t.timestamps
    end
    
    add_index :redwood_exports, :name
    add_index :redwood_exports, :status
    add_index :redwood_exports, [:xml_file_name, :xml_updated_at]
    add_index :redwood_exports, :uuid
    
    create_table :redwood_events do |t|
      t.string      :event
      t.references  :redwood_export
      t.references  :loan
      t.string      :uuid
      t.timestamps
    end
    
    add_index :redwood_events, :event
    add_index :redwood_events, [:loan_id, :redwood_export_id]
    add_index :redwood_events, :uuid
    
  end
end
