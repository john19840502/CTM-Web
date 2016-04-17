
#these are some methods that are included by several of the fhlmc loan thingies for
#cleaning some of the data out of compass loan details before formatting it or
#preparing it for uldd export.
module Smds
  module DataCleanupMethods
    def extract(source, max_length = 0)
      return '' if source == 'NA'
      return source if max_length == 0
      source.to_s[0...max_length]
    end

    def format_num(source, decimal_places = 0, opts = {})
      options = {
        default: '',
      }.merge opts

      return options[:default] if source.nil?
      value = source.to_f
      return options[:default] unless value > 0
      "%.#{decimal_places}f" % value
    end

    def format_date(source)
      return '' if source == Date.new(1900, 1, 1)
      return source.strftime("%Y-%m-%d")
    end

    def restrict_value_to(value, *args)
      return '' unless args.include?(value)
      value
    end

    def true_or_false(string)
      return false unless string.respond_to?(:downcase)
      return true if string.downcase == 'y'
      return true if string.downcase == 'yes'
      return false
    end

    def home_ready? # For FHLMC, FHLB Home Ready is not required
      false
    end
  end
end


