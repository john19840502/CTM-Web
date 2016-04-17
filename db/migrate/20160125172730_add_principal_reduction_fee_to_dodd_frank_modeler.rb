class AddPrincipalReductionFeeToDoddFrankModeler < ActiveRecord::Migration
  def change
    add_column :dodd_frank_modelers, :principal_reduction_fee, :decimal, precision: 6, scale: 2
  end
end
