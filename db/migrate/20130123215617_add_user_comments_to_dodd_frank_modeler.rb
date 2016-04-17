class AddUserCommentsToDoddFrankModeler < ActiveRecord::Migration
  def change
    add_column :frank_dodd_modellers, :user_comments, :string    
  end
end
