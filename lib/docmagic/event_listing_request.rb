module DocMagic

  class EventListingRequest < DocMagic::AuthenticatedRequest

    def initialize configurations = {}
      @configurations = configurations
    end

    def parse_xml_response content
      Rails.logger.debug content
      response = OpenStruct.new
      msg = Hash.from_xml content
      populate_success msg, response
      populate_messages msg, response
      response.listings = collection_array(msg, "DocMagicESignResponse", "PackageResponse", "PackageListings", "PackageListing").map{|l| DocMagic::PackageInfo.new(l)}
      response
    end

    def set_default_values response
      response.listings = []
    end

    def url
      u = base_url + "webservices/esign/api/v2/packages"
      if start_date
        fin = end_date || start_date
        u += "/#{start_date},#{fin}"
      elsif loan_num
        u += "/search?OriginatorReferenceIdentifier=#{loan_num}"
      end
      u
    end

    def self.for_date start_date
      new({start_date: start_date})
    end

    def self.for_date_range start_date, end_date
      new({start_date: start_date, end_date: end_date})
    end

    def self.for_loan_num loan_num
      new({loan_num: loan_num})
    end

    private

    def parse_messages message, response
      msgs = message["DocMagicESignResponse"]["Messages"]
      response.message = msgs["Message"] unless msgs.nil?
    end

    def loan_num
      @configurations[:loan_num]
    end

    def start_date
      format @configurations[:start_date]
    end

    def end_date
      format @configurations[:end_date]
    end

    def format date
      date.strftime "%Y-%m-%d" unless date.nil?
    end

  end

end