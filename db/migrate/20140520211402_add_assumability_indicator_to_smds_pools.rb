class AddAssumabilityIndicatorToSmdsPools < ActiveRecord::Migration
  def change
    add_column :smds_pools, :assumability_indicator, :boolean
  end
end
