require 'spec_helper'
require 'docmagic'

describe DocMagic::EventSignerTokenRequest do

  context ".parse_html_response" do

    it "should handle HTML error response" do
      request = DocMagic::EventSignerTokenRequest.new "8769", "S_765"
      msg = request.parse_html_response access_forbidden
      expect(msg.success).to be_falsey
      expect(msg.messages.size).to eq 1
      expect(msg.messages[0]).to eq "Access to the specified resource has been forbidden."
      expect(msg.signer_actions).to eq []
      expect(msg.signers).to eq []
    end

    def access_forbidden
      "<html><head><title>Apache Tomcat/7.0.52 - Error report</title><style><!--H1 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:22px;} H2 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:16px;} H3 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:14px;} BODY {font-family:Tahoma,Arial,sans-serif;color:black;background-color:white;} B {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;} P {font-family:Tahoma,Arial,sans-serif;background:white;color:black;font-size:12px;}A {color : black;}A.name {color : black;}HR {color : #525D76;}--></style> </head><body><h1>HTTP Status 403 - message</h1><HR size=\"1\" noshade=\"noshade\"><p><b>type</b> Status report</p><p><b>message</b> <u>message</u></p><p><b>description</b> <u>Access to the specified resource has been forbidden.</u></p><HR size=\"1\" noshade=\"noshade\"><h3>Apache Tomcat/7.0.52</h3></body></html>"
    end

  end

  describe ".parse_xml_response" do

    it "should read token" do
      request = DocMagic::EventSignerTokenRequest.new "71128", "S_124373"
      msg = request.parse_xml_response message
      expect(msg.success).to be_truthy
      actions = msg.signer_actions
      expect(actions.size).to eq 1
      expect(actions[0].signer_id).to eq "S_124373"
      expect(actions[0].consent_approved_date).to eq "2016-02-15T10:57:54.000-05:00".to_time
      expect(actions[0].signer_id_number).to eq "124373"
      expect(actions[0].start_date).to eq "2016-02-15T10:57:50.000-05:00".to_time
      signers = msg.signers
      expect(signers.size).to eq 1
      expect(signers[0].signer_id).to eq "S_124373"
      expect(signers[0].email).to eq "hpaholak@mbmortgage.com"
      expect(signers[0].first_name).to eq "Mortgage"
      expect(signers[0].last_name).to eq "Sample"
      expect(signers[0].full_name).to eq "Mortgage Sample"
      expect(signers[0].token_id).to eq "UzVRMlY3UzUANVVl"
      expect(signers[0].verification_irs_4506_uri).to eq "/webservices/esign/api/v2/packages/71128/signers/S_124373/verifications/IRS4506"
    end

    def message
      "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
      "<DocMagicESignResponse xmlns=\"http://www.docmagic.com/2011/schemas\" status=\"Success\">" +
      "<PackageResponse>" +
      "<Package>" +
      "<SignerActions>" +
      "<SignerAction signerID=\"S_124373\">" +
      "<ConsentApprovedDate>2016-02-15T07:57:54.000-08:00</ConsentApprovedDate>" +
      "<SignerIdentifier>124373</SignerIdentifier>" +
      "<StartDate>2016-02-15T07:57:50.000-08:00</StartDate>" +
      "</SignerAction>" +
      "</SignerActions>" +
      "<Signers>" +
      "<Signer signerID=\"S_124373\">" +
      "<EmailValue>hpaholak@mbmortgage.com</EmailValue>" +
      "<FirstName>Mortgage</FirstName>" +
      "<FullName>Mortgage Sample</FullName>" +
      "<LastName>Sample</LastName>" +
      "<TokenIdentifier>UzVRMlY3UzUANVVl</TokenIdentifier>" +
      "<VerificationIRS4506URI>/webservices/esign/api/v2/packages/71128/signers/S_124373/verifications/IRS4506</VerificationIRS4506URI>" +
      "</Signer>" +
      "</Signers>" +
      "</Package>" +
      "</PackageResponse>" +
      "</DocMagicESignResponse>"
    end
  end

  describe ".url" do

    it "should contain package and signer id" do
      request = DocMagic::EventSignerTokenRequest.new "71128", "S_124373"
      expect(request.url).to eq "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71128/signers/S_124373"
    end

  end

end