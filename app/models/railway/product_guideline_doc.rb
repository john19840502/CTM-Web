class ProductGuidelineDoc < DatabaseRailway
  belongs_to :product_guideline
  attr_accessible :product_guideline_id, :effective_date, :document, :channel
  
  has_attached_file :document

  validates :effective_date, :channel, :document, presence: true

  validates_attachment_presence :document
  validates_attachment_content_type :document,
                              content_type: "application/pdf",
                              message: 'must be PDF'

  def to_label
    "Guideline Document for Product Code #{product_guideline.product_code}"
  end
end
