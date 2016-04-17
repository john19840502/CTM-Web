module DocMagic

  class AuthenticationRequest < DocMagic::Request

    def request_xml
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
      "<DocMagicAuthenticationRequest xmlns=\"http://www.docmagic.com/2011/schemas\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" originatorType=\"ThirdPartyServer\">" +
      "<AccountIdentifier>#{DOCMAGIC_ACCOUNT_IDENTIFIER}</AccountIdentifier>" +
      "<AccountUserPassword>#{DOCMAGIC_ACCOUNT_PASSWORD}</AccountUserPassword>" +
      "<AccountUserName>#{DOCMAGIC_ACCOUNT_USER_NAME}</AccountUserName>" +
      "</DocMagicAuthenticationRequest>"
    end

    def parse_xml_response content
      Rails.logger.debug content

      msg = Hash.from_xml content
      response = OpenStruct.new
      response.success = parse_success msg
      response.token = token_value msg
      response.seconds_before_expire = expiration_count msg
      response
    end

    def url
      base_url + "webservices/tokens"
    end

    def send_request http, uri, headers
      data = request_xml

      Rails.logger.debug "path: #{uri.path}"
      Rails.logger.debug "headers: #{headers}"
      Rails.logger.debug "data: #{data}"
      
      post http, uri.path, headers, data
    end

    def request_headers
      {'Content-Type' => 'text/xml'}
    end

    def set_default_values response
      response.seconds_before_expire = 0
    end

    private

    def parse_success message
      is_success? auth_response(message)
    end

    def token_value message
      token = access_token message
      token["TokenValue"] unless token.nil?
    end

    def expiration_count message
      token = access_token message
      return 0 if token.nil?
      token["TokenExpirationSecondsCount"].to_i
    end

    def access_token message
      auth_response(message)["AccessToken"]
    end

    def auth_response message
      message["DocMagicAuthenticationResponse"]
    end

  end

end