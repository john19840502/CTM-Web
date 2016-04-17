require 'spec_helper'

describe Esign::EventDetailsHelper do

  describe ".actions_for_signer" do

    let(:actions) {
      [ OpenStruct.new(signer_id: "S_12345", test_id: 1),
        OpenStruct.new(signer_id: "S_23456", test_id: 2), 
        OpenStruct.new(signer_id: "S_12345", test_id: 3),
        OpenStruct.new(signer_id: "S_34566", test_id: 4)]
    }

    it "should filter the actions by given signer" do
      assign(:signer_actions, actions)
      retVal = helper.actions_for_signer "S_12345"
      expect(retVal.size).to eq 2
      expect(retVal[0].test_id).to eq 1
      expect(retVal[1].test_id).to eq 3
    end

    it "should handle unfound signer" do
      assign(:signer_actions, actions)
      retVal = helper.actions_for_signer "S_98765"
      expect(retVal.size).to eq 0
    end

  end

  describe ".date_time" do

    it "should format a datetime" do
      date = DateTime.new(2015, 9, 28, 17, 34, 20)
      expect(helper.date_time(date)).to eq "09/28/2015 05:34 PM"
    end

    it "should handle nil" do
      expect(helper.date_time(nil)).to be_nil
    end

  end

end