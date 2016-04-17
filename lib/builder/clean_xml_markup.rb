#This is a version of the XmlMarkup Builder which does not allow empty elements.
module Builder
  class CleanXmlMarkup < XmlMarkup
    def tag!(sym, *args, &block)
      text = nil
      attrs = nil
      sym = "#{sym}:#{args.shift}" if args.first.kind_of?(::Symbol)
      sym = sym.to_sym unless sym.class == ::Symbol
      args.each do |arg|
        case arg
        when ::Hash
          attrs ||= {}
          attrs.merge!(arg)
        when nil
          attrs ||= {}
          attrs.merge!({:nil => true}) if explicit_nil_handling?
        else
          text ||= ''
          #BEGIN CUSTOM CODE
          text << arg.to_s.strip
          #END CUSTOM CODE
        end
      end
      if block
        unless text.nil?
          ::Kernel::raise ::ArgumentError,
                          "XmlMarkup cannot mix a text argument with a block"
        end
        _indent
        _start_tag(sym, attrs)
        _newline
        begin
          _nested_structures(block)
        ensure
          _indent
          _end_tag(sym)
          _newline
        end
      #BEGIN CUSTOM CODE
      elsif text.blank?
        #_indent
        #_start_tag(sym, attrs, true)
        #_newline
      #END CUSTOM CODE
      else
        _indent
        _start_tag(sym, attrs)
        text! text
        _end_tag(sym)
        _newline
      end
      @target
    end
  end
end