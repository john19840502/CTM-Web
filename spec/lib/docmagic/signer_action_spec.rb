require 'spec_helper'
require 'docmagic'

describe DocMagic::SignerAction do

  describe ".initialization" do

    it "should extract values from hash" do
      hash = {"signerID" => "S_124534", "ConsentApprovedDate" => "2016-02-15T07:57:54.000-08:00",
              "SignerIdentifier" => "124534", "StartDate" => "2016-02-16T12:45:19.000-08:00"}
      action = DocMagic::SignerAction.new hash
      expect(action.signer_id).to eq "S_124534"
      expect(action.signer_id_number).to eq "124534"
      expect(action.consent_approved_date).to eq "2016-02-15T10:57:54.000-05:00".to_time
      expect(action.start_date).to eq "2016-02-16T12:45:19.000-08:00"
      expect(action.completed_date).to be_nil
    end

    it "should handle empty start date" do
      hash = {"signerID" => "S_124537", "ConsentApprovedDate" => "2016-02-16T11:35:39.000-08:00",
              "SignerIdentifier" => "124537"}
    action = DocMagic::SignerAction.new hash
      expect(action.signer_id).to eq "S_124537"
      expect(action.signer_id_number).to eq "124537"
      expect(action.consent_approved_date).to eq "2016-02-16T14:35:39.000-05:00".to_time
      expect(action.start_date).to be_nil
      expect(action.completed_date).to be_nil
    end

    it "should read completed date when available" do
      hash = { "signerID" => "S_130157", "CompletedDate" => "2016-03-17T05:54:40.000-07:00",
               "ConsentApprovedDate" => "2016-03-15T11:25:46.000-07:00", 
               "SignerIdentifier" => "130157", "StartDate" => "2016-03-17T05:46:45.000-07:00" }

      action = DocMagic::SignerAction.new hash
      expect(action.signer_id).to eq "S_130157"
      expect(action.signer_id_number).to eq "130157"
      expect(action.consent_approved_date).to eq "2016-03-15T13:25:46.000-05:00".to_time
      expect(action.start_date).to eq "2016-03-17T07:46:45.000-05:00".to_time
      expect(action.completed_date).to eq "2016-03-17T07:54:40.000-05:00".to_time
    end

  end

end