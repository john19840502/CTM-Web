require 'spec_helper'
require 'docmagic'

describe DocMagic::DocumentListing do

  context ".initialize" do

    it "should load from minimal hash" do
      hash = {"DocumentDescription" => "INITIAL DISCLOSURE COVER LETTER", 
              "DocumentIdentifier" => "1169830", "DocumentName" => "iidi2.mbf.xml",
              "TotalNumberOfPagesCount" => "2"} 
      listing = DocMagic::DocumentListing.new hash
      expect(listing.description).to eq "INITIAL DISCLOSURE COVER LETTER"
      expect(listing.document_id).to eq "1169830"
      expect(listing.document_name).to eq "iidi2.mbf.xml"
      expect(listing.total_page_count).to eq 2
      expect(listing.document_marks).to eq []
    end

  end

end