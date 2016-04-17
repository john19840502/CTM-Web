module DocMagic

  class EventSignerTokenRequest < AuthenticatedRequest

    attr_accessor :package_id, :signer_id

    def initialize package_id, signer_id
      self.package_id = package_id
      self.signer_id = signer_id
    end

    def parse_xml_response content
      Rails.logger.debug content
      msg = Hash.from_xml content
      response = OpenStruct.new
      populate_success msg, response
      populate_messages msg, response
      response.signer_actions = collection_array(msg, "DocMagicESignResponse", "PackageResponse", 
                  "Package", "SignerActions", "SignerAction").map{|a| DocMagic::SignerAction.new(a)}
      response.signers = collection_array(msg, "DocMagicESignResponse", "PackageResponse", 
                  "Package", "Signers", "Signer").map{|s| DocMagic::Signer.new(s)}
      response
    end

    def set_default_values response
      response.signer_actions = []
      response.signers = []
    end

    def url
      "#{base_url}webservices/esign/api/v2/packages/#{package_id}/signers/#{signer_id}"
    end

  end

end