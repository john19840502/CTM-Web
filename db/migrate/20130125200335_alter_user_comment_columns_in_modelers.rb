class AlterUserCommentColumnsInModelers < ActiveRecord::Migration
  def change
    change_column :freddie_relief_modelers, :user_comments, :text    
    change_column :funding_modelers, :user_comments, :text    
  end
end
