require 'spec_helper'
require 'docmagic'

describe DocMagic::AuthenticationRequest do

  context ".request_xml" do

    it "should include the account information" do
      msg = subject.request_xml
      expect(msg).to include "test-account-un"
      expect(msg).to include "test-account-id"
      expect(msg).to include "test-account-pw"
    end

  end

  context ".parse_html_response" do

    it "should handle HTML error response" do
      msg = subject.parse_html_response access_forbidden
      expect(msg.success).to be_falsey
      expect(msg.messages.size).to eq 1
      expect(msg.messages[0]).to eq "Access to the specified resource has been forbidden."
      expect(msg.token).to be_nil
      expect(msg.seconds_before_expire).to eq 0
    end

    def access_forbidden
      "<html><head><title>Apache Tomcat/7.0.52 - Error report</title><style><!--H1 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:22px;} H2 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:16px;} H3 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:14px;} BODY {font-family:Tahoma,Arial,sans-serif;color:black;background-color:white;} B {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;} P {font-family:Tahoma,Arial,sans-serif;background:white;color:black;font-size:12px;}A {color : black;}A.name {color : black;}HR {color : #525D76;}--></style> </head><body><h1>HTTP Status 403 - message</h1><HR size=\"1\" noshade=\"noshade\"><p><b>type</b> Status report</p><p><b>message</b> <u>message</u></p><p><b>description</b> <u>Access to the specified resource has been forbidden.</u></p><HR size=\"1\" noshade=\"noshade\"><h3>Apache Tomcat/7.0.52</h3></body></html>"
    end

  end

  context ".parse_xml_response" do

    it "successful response should contain the token details" do
      msg = subject.parse_xml_response message
      expect(msg.success).to be_truthy
      expect(msg.token).to eq "VEdULTQzODUtYmo0czlmcmpxdzVNbkxtYWRBRGRqRXRET2xNY3hZdlhkMTR5YXVBSlNBb0RyYlpjVW0tY2Fz"
      expect(msg.seconds_before_expire).to eq 7200
    end

    it "failure message should report failure" do
      msg = subject.parse_xml_response failure
      expect(msg.success).to be_falsey
      expect(msg.token).to be_nil
      expect(msg.seconds_before_expire).to eq 0
    end

    def message
      "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
      "<DocMagicAuthenticationResponse xmlns=\"http://www.docmagic.com/2011/schemas\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" status=\"Success\">" +
      "<AccessToken>" +
      "<TokenValue contentEncodingType=\"Base64\">VEdULTQzODUtYmo0czlmcmpxdzVNbkxtYWRBRGRqRXRET2xNY3hZdlhkMTR5YXVBSlNBb0RyYlpjVW0tY2Fz</TokenValue>" +
      "<TokenExpirationSecondsCount>7200</TokenExpirationSecondsCount>" +
      "</AccessToken>" +
      "</DocMagicAuthenticationResponse>"
    end

    def failure
      "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
      "<DocMagicAuthenticationResponse xmlns=\"http://www.docmagic.com/2011/schemas\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" status=\"Failure\"/>"
    end

  end

  context ".url" do

    it "should go to the authentication address" do
      expect(subject.url).to eq "https://stage-www.docmagic.com/webservices/tokens"
    end

  end
  
end