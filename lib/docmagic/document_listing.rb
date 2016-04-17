module DocMagic

  class DocumentListing

    attr_accessor :description, :document_id, :document_name, :total_page_count, :document_marks

    def initialize listing_hash
      self.description = listing_hash["DocumentDescription"]
      self.document_id = listing_hash["DocumentIdentifier"]
      self.document_name = listing_hash["DocumentName"]
      self.total_page_count = listing_hash["TotalNumberOfPagesCount"].to_i
      self.document_marks = []
    end

  end

end