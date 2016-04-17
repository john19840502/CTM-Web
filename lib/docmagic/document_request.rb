module DocMagic

  class DocumentRequest < AuthenticatedRequest

    attr_accessor :package_id, :signer_id

    def initialize package_id, signer_id = nil
      self.package_id = package_id
      self.signer_id = signer_id
    end

    def parse_xml_response content
      Rails.logger.debug content
      msg = Hash.from_xml content
      response = OpenStruct.new
      populate_success msg, response
      populate_messages msg, response
      doc_response = msg["DocMagicESignResponse"]["DocumentResponse"]
      response.package_id = doc_response["DocumentPackage"]["PackageIdentifier"] if doc_response
      response.document_listings = collection_array(doc_response, "DocumentPackage", "DocumentListings", "DocumentListing").map{|l| DocMagic::DocumentListing.new(l)}
      response.package_content = doc_response["DocumentPackage"]["DocumentPackageContent"] if doc_response
      response
    end

    def set_default_values response
      response.document_listings = []
    end

    def url
      if signer_id
        "#{base_url}webservices/esign/api/v2/packages/#{package_id}/signers/#{signer_id}/verifications/IRS4506"
      else
        "#{base_url}webservices/esign/api/v2/packages/#{package_id}/documents"
      end
    end

  end

end