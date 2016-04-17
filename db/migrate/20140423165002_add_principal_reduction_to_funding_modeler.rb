class AddPrincipalReductionToFundingModeler < ActiveRecord::Migration
  def change
    add_column :funding_modelers, :principal_reduction, :string
  end
end
