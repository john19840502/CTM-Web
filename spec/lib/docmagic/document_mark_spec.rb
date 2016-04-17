require 'spec_helper'
require 'docmagic'

describe DocMagic::DocumentMark do

  context ".initialize" do

    it "should read the data from the hash" do
      hash = {"signerID" => "S_124373", "documentMarkType" => "Signature",
              "offsetMeasurementUnitType" => "Pixels", "DocumentMarkIdentifier" => "2235218",
              "OffsetFromBottomNumber" => "262.0", "OffsetFromLeftNumber" => "72.0",
              "PageNumberCount" => "1"}
      mark = DocMagic::DocumentMark.new hash
      expect(mark.signer_id).to eq "S_124373"
      expect(mark.mark_type).to eq "Signature"
      expect(mark.offset_units).to eq "Pixels"
      expect(mark.mark_id).to eq "2235218"
      expect(mark.bottom_offset).to eq "262.0"
      expect(mark.left_offset).to eq "72.0"
      expect(mark.page_number_count).to eq "1"
    end

  end

end
