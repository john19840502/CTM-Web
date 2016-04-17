require 'spec_helper'

describe Esign::DocumentListingsHelper do

  describe ".signer_name" do

    let(:signers) {
      [ OpenStruct.new(signer_id: "S_12345", full_name: "Tuesday Sample"),
        OpenStruct.new(signer_id: "S_23456", full_name: "Wednesday Sample"), 
        OpenStruct.new(signer_id: "S_34567", full_name: "Thomas Sample"),
        OpenStruct.new(signer_id: "S_45678", full_name: "Test LO1")]
    }

    it "should the name of a mapped signer" do
      assign(:signers, signers)
      expect(helper.signer_name "S_34567").to eq "Thomas Sample"
    end

    it "should handle unfound signer" do
      assign(:signers, signers)
      expect(helper.signer_name "S_98765").to eq "[Unknown User: S_98765]"
    end

    it "should handle missing id" do
      assign(:signers, signers)
      expect(helper.signer_name nil).to eq "[Not yet signed]"
    end

    it "should handle unset signers" do
      assign(:signers, nil)
      expect(helper.signer_name "S_23456").to eq "[Not yet signed]"
    end

    it "should handle empty signers list" do
      assign(:signers, [])
      expect(helper.signer_name "S_23456").to eq "[Not yet signed]"
    end

  end

end