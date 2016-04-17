class CreateEditNotes < ActiveRecord::Migration
  def change
    create_table :edit_notes do |t|
    	t.integer :user_id
    	t.string :note_type, limit: 50
    	t.text   :note
      t.timestamps
    end
  end
end
