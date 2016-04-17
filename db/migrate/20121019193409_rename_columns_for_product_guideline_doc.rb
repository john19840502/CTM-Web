class RenameColumnsForProductGuidelineDoc < ActiveRecord::Migration
  def change
    rename_column :product_guideline_docs, :doc_file_name, :document_file_name
    rename_column :product_guideline_docs, :doc_content_type, :document_content_type
    rename_column :product_guideline_docs, :doc_file_size, :document_file_size
    rename_column :product_guideline_docs, :doc_updated_at, :document_updated_at
  end
end
