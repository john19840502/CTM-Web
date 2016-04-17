class CreateClosingChecklists < ActiveRecord::Migration
  def change
    create_table :closing_checklists do |t|
      t.integer :loan_num
      
      t.timestamps
    end

    create_table :checklist_answers do |t|
      t.integer :checklist_id

      t.string :name
      t.string :answer
      t.datetime :answered_at
      t.string :answered_by
    end
  end
end
