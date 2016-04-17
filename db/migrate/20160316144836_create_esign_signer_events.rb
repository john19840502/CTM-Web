class CreateEsignSignerEvents < ActiveRecord::Migration
  def change
    create_table :esign_signer_events do |t|
      t.string :event_type
      t.integer :esign_signer_id
      t.timestamp :event_date
      t.string :event_note
      t.integer :loan_number
    end
  end
end
