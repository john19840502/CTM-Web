class AddMortgageInsurancePremiumToDoddFrankModeler < ActiveRecord::Migration
  def change
    add_column :dodd_frank_modelers, :mortgage_insurance_premium, :string
  end
end
