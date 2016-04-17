class AddPremiumPricingToFrankDoddModeller < ActiveRecord::Migration
  def change
    add_column :frank_dodd_modellers, :premium_pricing, :string
  end
end
