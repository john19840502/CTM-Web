class CreateEsignDocuments < ActiveRecord::Migration
  def change
    create_table :esign_documents do |t|
      t.integer :loan_number
      t.string :document_description
      t.string :document_name
      t.integer :page_count
      t.string :external_document_id
    end

    add_index :esign_documents, :external_document_id
  end
end
