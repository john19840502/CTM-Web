class AddGrmaFeeToFundingModeler < ActiveRecord::Migration
  def change
    add_column :funding_modelers, :grma_fee, :string
  end
end
