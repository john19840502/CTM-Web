class CreateProductData < ActiveRecord::Migration
  def change
    create_table :product_data do |t|
      t.string :loan_type
      t.string :program
      t.string :price_code
      t.string :amortization_type
      t.string :amortization_term
      t.string :product_code
      t.string :bfn_gfe_mortgage_product_type
      t.string :bfn_loan_product_name
      t.string :product_name

      t.timestamps
    end

    add_index :product_data, :product_code
  end
end
