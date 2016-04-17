class AlterUserCommentsColumnInDoddFrank < ActiveRecord::Migration
  def change
    change_column :frank_dodd_modellers, :user_comments, :text    
  end
end
