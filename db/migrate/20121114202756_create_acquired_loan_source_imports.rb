class CreateAcquiredLoanSourceImports < ActiveRecord::Migration
  def change
    create_table :acquired_loan_source_imports do |t|
      t.string :name
      t.string :status, :default => "created"
      t.string :bundle_file_name
      t.string :bundle_content_type
      t.integer :bundle_file_size
      t.datetime :bundle_updated_at
      t.string :bundle_fingerprint

      t.timestamps
    end
  end
end
