class AddInvestorProductPlanIdentifierToSmdsPools < ActiveRecord::Migration
  def change
    unless column_exists? :smds_pools, :investor_product_plan_identifier
      add_column :smds_pools, :investor_product_plan_identifier, :string
    end
  end
end
