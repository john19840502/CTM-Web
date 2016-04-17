class ChangeUserIdTypeInEditNotes < ActiveRecord::Migration
  def up
  	change_column :edit_notes, :user_id, :string
  end

  def down
  	change_column :edit_notes, :user_id, :integer
  end
end
