class AddClosingCostToFrankDoddModeller < ActiveRecord::Migration
  def change
    add_column :frank_dodd_modellers, :closing_cost, :string
  end
end
