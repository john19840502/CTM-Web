class AddColumnsToFrankDoddModeler < ActiveRecord::Migration
  def change
    add_column :frank_dodd_modellers, :modeler_date_time, :string    
    add_column :frank_dodd_modellers, :modeler_user, :string    
  end
end
