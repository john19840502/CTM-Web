class CreateForcedRegistrations < ActiveRecord::Migration
  def change
    create_table :forced_registrations do |t|
      t.string      :loan_num
      t.string      :borrower
      t.string      :loan_officer
      t.datetime    :disclosure_date
      t.datetime    :intent_to_proceed_date
      t.string      :loan_status
      t.timestamps
    end

    add_index :forced_registrations, :loan_num
    add_index :forced_registrations, :intent_to_proceed_date
  end
end
