module DocMagic

  class DocumentMark

    attr_accessor :signer_id, :mark_type, :offset_units, :mark_id, :bottom_offset, :left_offset,
                  :page_number_count

    def initialize mark_hash
      self.signer_id = mark_hash["signerID"]
      self.mark_type = mark_hash["documentMarkType"]
      self.offset_units = mark_hash["offsetMeasurementUnitType"]
      self.bottom_offset = mark_hash["OffsetFromBottomNumber"]
      self.mark_id = mark_hash["DocumentMarkIdentifier"]
      self.left_offset = mark_hash["OffsetFromLeftNumber"]
      self.page_number_count = mark_hash["PageNumberCount"]
    end

  end

end