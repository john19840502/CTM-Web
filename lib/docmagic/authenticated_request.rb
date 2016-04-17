module DocMagic

  class AuthenticatedRequest < DocMagic::Request

    def request_headers
      {"Authorization" => "Bearer #{token}"}
    end

    def send_request http, uri, headers
      Rails.logger.debug "Path: #{uri.path}"
      Rails.logger.debug "Headers: #{headers}"
      Rails.logger.debug "Query: #{uri.query}"

      path = uri.query ? "#{uri.path}?#{uri.query}" : uri.path
      get http, path, headers
    end

    def populate_success message, response
      response.success = is_success? message["DocMagicESignResponse"]
    end

    def collection_array root, *key
      recursive_collection_array root, key
    end

    def date_time value
      value.try!(:to_time)
    end

    def populate_messages message, response
      response.messages = collection_array(message, "DocMagicESignResponse", "Messages", "Message")
    end

    private

    def recursive_collection_array hash, key_arr
      return [] if hash.nil? || key_arr.nil?
      array_candidate = hash[key_arr.shift]

      if key_arr.empty?
        return [] if array_candidate.nil?
        array_candidate.kind_of?(Array) ? array_candidate : [array_candidate]
      else
        recursive_collection_array array_candidate, key_arr
      end
    end

    def token
      auth_token = DocMagic::AuthenticationToken.token
      auth_token.string_token unless auth_token.nil?
    end

  end

end