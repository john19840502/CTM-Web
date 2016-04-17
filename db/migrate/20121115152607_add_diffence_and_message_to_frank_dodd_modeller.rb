class AddDiffenceAndMessageToFrankDoddModeller < ActiveRecord::Migration
  def change
    add_column :frank_dodd_modellers, :difference, :string
    add_column :frank_dodd_modellers, :message, :string
  end
end
