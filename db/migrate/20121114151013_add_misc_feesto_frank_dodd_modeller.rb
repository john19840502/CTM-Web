class AddMiscFeestoFrankDoddModeller < ActiveRecord::Migration
  def change
    add_column :frank_dodd_modellers, :misc_fees_1, :string
    add_column :frank_dodd_modellers, :misc_fees_2, :string
    add_column :frank_dodd_modellers, :misc_fees_3, :string
    add_column :frank_dodd_modellers, :misc_fees_4, :string
  end
end
