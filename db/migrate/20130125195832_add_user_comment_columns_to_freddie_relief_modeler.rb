class AddUserCommentColumnsToFreddieReliefModeler < ActiveRecord::Migration
  def change
    add_column :freddie_relief_modelers, :modeler_date_time, :string    
    add_column :freddie_relief_modelers, :modeler_user, :string    
    add_column :freddie_relief_modelers, :user_comments, :string    
  end
end
