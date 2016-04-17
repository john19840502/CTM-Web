class CreateEsignSignatureLines < ActiveRecord::Migration
  def change
    create_table :esign_signature_lines do |t|
      t.integer :esign_document_id
      t.string :signature_line_type
      t.string :external_signature_line_id
      t.integer :esign_signer_id
      t.integer :page_number
    end

    add_index :esign_signature_lines, :external_signature_line_id
  end
end
