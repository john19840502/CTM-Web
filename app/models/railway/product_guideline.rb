class ProductGuideline < DatabaseRailway
  has_many :product_guideline_docs, :dependent => :delete_all
  attr_accessible :product_code

  validates :product_code, presence: true, uniqueness: true

  def to_label
    "Product Code: #{product_code}"
  end

  def current_guideline(channel)
    guideline_doc channel, Date.tomorrow
  end

  def guideline_doc(chnl, dt)
    product_guideline_docs.where{ channel.eq(chnl) }.where { effective_date <  dt }.order{ effective_date }.last
  end

  def self.loan_guideline_doc(product_code, channel, loan_effective_date)
    pg = ProductGuideline.find_by_product_code(product_code)
    (pg and loan_effective_date) ? pg.guideline_doc(channel, loan_effective_date) : nil
  end
end
