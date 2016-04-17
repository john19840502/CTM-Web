class CreateProductGuideline < ActiveRecord::Migration
  def change
    create_table :product_guidelines do |t|
      t.string      :product_code
      t.date        :effective_date
      t.timestamps
    end
    
    add_index :product_guidelines, [:product_code]
  end
end
