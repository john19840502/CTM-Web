module DocMagic

  class EventDetailRequest < DocMagic::AuthenticatedRequest

    attr_accessor :package_id

    def initialize package_id
      self.package_id = package_id
    end

    def parse_xml_response content
      Rails.logger.debug content
      msg = Hash.from_xml content
      response = OpenStruct.new
      populate_success msg, response
      populate_messages msg, response
      package_response = msg["DocMagicESignResponse"]["PackageResponse"]
      package = package_response.nil? ? nil : package_response["Package"]
      response.package_info = DocMagic::PackageInfo.new package unless package.nil?
      response.listings = collection_array(package, "DocumentListings", "DocumentListing").map{|l| parse_listing(l)}
      response.events = collection_array(package, "Events", "Event").map{|e| DocMagic::Event.new(e)}
      response.signer_actions = collection_array(package, "SignerActions", "SignerAction").map{|a| DocMagic::SignerAction.new(a)}
      response.signers = collection_array(package, "Signers", "Signer").map{|s| DocMagic::Signer.new(s)}
      response.versions = collection_array(package, "VersionListings", "VersionListing").map{|v| DocMagic::VersionListing.new(v)}
      response
    end

    def set_default_values response
      response.listings = []
      response.events = []
      response.signers = []
      response.signer_actions = []
      response.versions = []
    end

    def url
      base_url + "webservices/esign/api/v2/packages/#{self.package_id}"
    end

    private

    def parse_listing document_listing
      listing = DocMagic::DocumentListing.new document_listing
      listing.document_marks = collection_array(document_listing, "DocumentMarks", "DocumentMark").map{|m| DocMagic::DocumentMark.new(m)}
      listing
    end

  end

end