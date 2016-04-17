class CreateFloridaCondoPdfs < ActiveRecord::Migration
  def up
    create_table :florida_condo_pdfs do |t|
    	t.string 	 		:pdf_file_name
      t.string      :pdf_file_label 
    	t.string   		:pdf_content_type
    	t.integer     :pdf_file_size
      t.timestamps
    end
  end

  def down
  	drop_table :florida_condo_pdfs
  end
end
