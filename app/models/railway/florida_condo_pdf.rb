class FloridaCondoPdf < DatabaseRailway
  # attr_accessible :title, :body
  attr_accessible :pdf_file_name, :pdf_content_type, :pdf_file_label

  has_attached_file :pdf

  validates_attachment :pdf, content_type: { content_type: ["application/pdf"]}

  PDF_URL = 'https://www.fanniemae.com/content/datagrid/condo_pud/condo_approved_projects_report-fl.pdf'

  def self.download_pdf
    require 'open-uri'
    perse = FloridaCondoPdf.new
    extname = File.extname(PDF_URL)
    basename = "Pers_"
    file = Tempfile.new([basename, extname])
    file.binmode

    open(URI.parse(PDF_URL)) do |data|
      file.write data.read
    end
    file.rewind

    perse.pdf = file
    perse.pdf_file_label = "Condo Approved Projects List #{Time.now.strftime("%B %Y")}"
    perse.save!
  end
end
