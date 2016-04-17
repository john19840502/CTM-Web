module DocMagic

  class Request

    def execute
      Rails.logger.debug "url: #{url}"

      headers = request_headers
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      
      #t1 = Time.now
      
      res = send_request http, uri, headers
      
      #time_in_milliseconds = (Time.now - t1) * 1000.0
      
      #ActiveSupport::Notifications.instrument('docmagic.execute', {name: 'DocMagic Execution', time_in_milliseconds: time_in_milliseconds})
      Rails.logger.debug "DocMagic Response: #{res}"
      create_response res.body
    end

    def create_response content
      if content.include? "<html>"
        parse_html_response content
      else
        parse_xml_response content
      end
    end

    def parse_html_response content
      response = OpenStruct.new
      response.success = false

      dom = Nokogiri::HTML content
      msg = dom.css("p").select{|p| p.css("b")[0].text == "description"}[0].css("u")[0].text
      response.messages = [msg]

      set_default_values response
      response
    end

    def is_success? root
      root["status"] == "Success"
    end

    def post http, path, headers, data
      http.post(path, data, headers)
    end

    def get http, path, headers
      http.get(path, headers)
    end

    def base_url
      DOCMAGIC_URL
    end

  end

end