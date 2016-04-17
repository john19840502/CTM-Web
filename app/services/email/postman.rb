module Email
  class Postman
    include ServiceObject

    attr_accessor :mail

    def initialize mail
      self.mail = mail
    end

    def call
      mail.deliver
      true
      rescue EOFError, Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
        Rails.logger.error ExceptionFormatter.new(e)
        Airbrake.notify e, params: {to: mail.to, from: mail.from, subject: mail.subject}
        false
    end

    def self.choose_valid_email email, alt_email
      return email if (email.present? && email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
      alt_email
    end

  end

end