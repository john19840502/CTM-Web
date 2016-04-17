class AddLoanDiscountToDoddFrankModeler < ActiveRecord::Migration
  def change
    add_column :dodd_frank_modelers, :loan_discount, :decimal, precision: 6, scale: 2
  end
end
