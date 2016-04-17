module Servicing
  class PayeeCode
    attr_accessor :prefix, :suffix

    def self.dummy
      PayeeCode.new '9999', '99901'
    end

    def initialize prefix, suffix = '00000'
      self.prefix = prefix
      self.suffix = suffix
    end
  end
end
