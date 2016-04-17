class AddUserCommentColumnsToFundingModeler < ActiveRecord::Migration
  def change
    add_column :funding_modelers, :modeler_date_time, :string    
    add_column :funding_modelers, :modeler_user, :string    
    add_column :funding_modelers, :user_comments, :string    
  end
end
