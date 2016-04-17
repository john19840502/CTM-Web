class ChangeColumnNameForProductGuidelineDocs < ActiveRecord::Migration
  def change
    rename_column :product_guideline_docs, :product_code_id, :product_guideline_id
  end
end
