module DocMagic

  class AuthenticationToken

    attr_accessor :string_token, :ts, :seconds_before_expire

    @@current_token = nil

    def initialize string_token, seconds_before_expire
      Rails.logger.debug "Creating new token with value: #{string_token}"
      self.string_token = string_token
      self.seconds_before_expire = seconds_before_expire
      self.ts = Time.now
    end

    def self.token
      if @@current_token.nil? || @@current_token.should_refresh?
        Rails.logger.debug "Retrieving new token"
        response = DocMagic::AuthenticationRequest.new.execute
        Rails.logger.debug response
        if !response.nil? && response.success
          @@current_token = new response.token, response.seconds_before_expire
        elsif !@@current_token.nil? && @@current_token.expired?
          @@current_token = nil
          Rails.logger.warn "Authentication refresh failed"
          Rails.logger.warn response
          Rails.logger.warn "Expired token: #{@@current_token}" if !@@current_token.nil?
          raise "No valid authentication token available."
        end
      end
      @@current_token
    end

    def should_refresh?
      stale? || expired?
    end

    def stale?
      10.minutes.ago > ts
    end

    def expired?
      Time.now > (ts + seconds_before_expire.seconds)
    end

  end

end