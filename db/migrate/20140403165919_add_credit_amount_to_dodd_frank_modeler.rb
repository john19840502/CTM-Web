class AddCreditAmountToDoddFrankModeler < ActiveRecord::Migration
  def change
    add_column :dodd_frank_modelers, :credit_amount, :string
    add_column :dodd_frank_modelers, :credit_amount_description, :string
  end
end
