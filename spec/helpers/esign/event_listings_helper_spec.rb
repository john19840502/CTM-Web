require 'spec_helper'

describe Esign::EventListingsHelper do

  describe ".detail_path" do

    it "should create a path that includes the angular placeholder" do
      expect(helper.detail_path).to eq "/esign/event_details/{{listing.package_id}}"
    end

  end

  describe ".document_path" do

    it "should create a path that includes the angular placeholder" do
      expect(helper.document_path).to eq "/esign/documents/{{listing.package_id}}.pdf"
    end

  end

end