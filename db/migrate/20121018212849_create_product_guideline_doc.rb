class CreateProductGuidelineDoc < ActiveRecord::Migration
  def change
    create_table :product_guideline_docs do |t|
      t.integer          :product_code_id
      t.date        :effective_date
      t.timestamps
    end
    
    add_index :product_guideline_docs, [:product_code_id, :effective_date]
  end
end
