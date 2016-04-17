class AddMiscOtherFeesToFrankDoddModeller < ActiveRecord::Migration
  def change
    add_column :frank_dodd_modellers, :misc_other_fees, :string    
  end
end
