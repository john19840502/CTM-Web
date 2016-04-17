require 'spec_helper'
require 'docmagic'

describe DocMagic::EventListingRequest do

  context ".set_default_values" do

    it "should set the empty values" do
      msg = OpenStruct.new
      subject.set_default_values msg
      expect(msg.listings).to eq []
    end

  end

  context ".parse_html_response" do

    it "should handle HTML error response" do
      msg = subject.parse_html_response access_forbidden
      expect(msg.success).to be_falsey
      expect(msg.messages.size).to eq 1
      expect(msg.messages[0]).to eq "Access to the specified resource has been forbidden."
      expect(msg.listings.size).to eq 0
    end

    def access_forbidden
      "<html><head><title>Apache Tomcat/7.0.52 - Error report</title><style><!--H1 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:22px;} H2 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:16px;} H3 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:14px;} BODY {font-family:Tahoma,Arial,sans-serif;color:black;background-color:white;} B {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;} P {font-family:Tahoma,Arial,sans-serif;background:white;color:black;font-size:12px;}A {color : black;}A.name {color : black;}HR {color : #525D76;}--></style> </head><body><h1>HTTP Status 403 - message</h1><HR size=\"1\" noshade=\"noshade\"><p><b>type</b> Status report</p><p><b>message</b> <u>message</u></p><p><b>description</b> <u>Access to the specified resource has been forbidden.</u></p><HR size=\"1\" noshade=\"noshade\"><h3>Apache Tomcat/7.0.52</h3></body></html>"
    end

  end

  context ".parse_xml_response" do

    it "should handle No Packages response" do
      msg = subject.parse_xml_response message_with_no_packages
      expect(msg.success).to be_truthy
      expect(msg.listings.size).to eq 0
      expect(msg.messages.size).to eq 1
      expect(msg.messages[0]).to eq "No Packages were found for the criteria provided."
    end

    it "should handle un-authenticated response" do
      msg = subject.parse_xml_response message_with_auth_failure
      expect(msg.success).to be_falsey
      expect(msg.listings.size).to eq 0
      expect(msg.messages.size).to eq 1
      expect(msg.messages[0]).to eq "Authentication Failure"
    end

    it "should contain basic information about package" do
      msg = subject.parse_xml_response message_with_single_package
      expect(msg.success).to be_truthy
      expect(msg.messages.size).to eq 0
      expect(msg.listings.size).to eq 1
      expect(msg.listings[0].create_date).to eq "2016-02-11T01:05:41.000-05:00".to_time
      expect(msg.listings[0].package_id).to eq "70976"
      expect(msg.listings[0].loan_number).to eq "6000484"
      expect(msg.listings[0].system_id).to eq "534672_6000484"
      expect(msg.listings[0].package_type).to eq "Predisclosure"
      expect(msg.listings[0].version_id).to eq 25
      expect(msg.listings[0].respa_status_type).to eq "Consented"
      expect(msg.listings[0].package_status_type).to eq "InProgress"
      expect(msg.listings[0].package_url).to eq "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70976"
    end

    it "should handle multiple packages" do
      msg = subject.parse_xml_response message_with_multiple_packages
      expect(msg.success).to be_truthy
      expect(msg.messages.size).to eq 0
      expect(msg.listings.size).to eq 35
    end

    def message_with_no_packages
      "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><DocMagicESignResponse xmlns=\"http://www.docmagic.com/2011/schemas\" status=\"Success\"><Messages><Message messageType=\"Info\" categoryType=\"Server\">No Packages were found for the criteria provided.</Message></Messages></DocMagicESignResponse>"
    end

    def message_with_multiple_packages
      "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><DocMagicESignResponse xmlns=\"http://www.docmagic.com/2011/schemas\" status=\"Success\"><PackageResponse><PackageListings><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T11:48:24Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71030</PackageIdentifier><VersionIdentifier>23</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71030</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T11:45:49Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71029</PackageIdentifier><VersionIdentifier>22</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71029</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T11:41:55Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71028</PackageIdentifier><VersionIdentifier>21</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71028</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T11:36:38Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71027</PackageIdentifier><VersionIdentifier>20</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71027</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T11:34:36Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71026</PackageIdentifier><VersionIdentifier>19</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71026</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T11:23:33Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71023</PackageIdentifier><VersionIdentifier>18</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71023</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T11:20:37Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71021</PackageIdentifier><VersionIdentifier>17</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71021</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T11:14:16Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71020</PackageIdentifier><VersionIdentifier>16</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71020</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T11:11:35Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71019</PackageIdentifier><VersionIdentifier>15</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71019</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T11:06:46Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71018</PackageIdentifier><VersionIdentifier>14</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71018</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T10:58:31Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71017</PackageIdentifier><VersionIdentifier>13</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71017</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T10:53:19Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71016</PackageIdentifier><VersionIdentifier>12</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71016</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T10:50:18Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71015</PackageIdentifier><VersionIdentifier>11</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71015</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T10:47:41Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71013</PackageIdentifier><VersionIdentifier>10</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71013</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T10:43:39Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71011</PackageIdentifier><VersionIdentifier>9</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71011</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T10:39:15Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71010</PackageIdentifier><VersionIdentifier>8</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71010</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T10:24:44Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71008</PackageIdentifier><VersionIdentifier>7</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71008</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T09:46:31Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>71000</PackageIdentifier><VersionIdentifier>6</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71000</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T09:44:41Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>70999</PackageIdentifier><VersionIdentifier>5</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70999</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T09:41:44Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>70998</PackageIdentifier><VersionIdentifier>4</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70998</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T09:32:50Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>70997</PackageIdentifier><VersionIdentifier>3</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70997</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T09:24:47Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>70996</PackageIdentifier><VersionIdentifier>2</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70996</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Unknown\" packageStatusType=\"New\"><CreateDate>2016-02-11T09:23:09Z</CreateDate><OriginatorReferenceIdentifier>1000647</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_1000647</OriginatorSystemIdentifier><PackageIdentifier>70995</PackageIdentifier><VersionIdentifier>1</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70995</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T08:38:55Z</CreateDate><OriginatorReferenceIdentifier>6000484</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_6000484</OriginatorSystemIdentifier><PackageIdentifier>70993</PackageIdentifier><VersionIdentifier>26</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70993</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-11T06:05:41Z</CreateDate><OriginatorReferenceIdentifier>6000484</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_6000484</OriginatorSystemIdentifier><PackageIdentifier>70976</PackageIdentifier><VersionIdentifier>25</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70976</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"Consented\"><CreateDate>2016-02-10T11:49:31Z</CreateDate><OriginatorReferenceIdentifier>6000484</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_6000484</OriginatorSystemIdentifier><PackageIdentifier>70913</PackageIdentifier><VersionIdentifier>11</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70913</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-10T11:39:40Z</CreateDate><OriginatorReferenceIdentifier>6000484</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_6000484</OriginatorSystemIdentifier><PackageIdentifier>70910</PackageIdentifier><VersionIdentifier>10</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70910</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-10T11:36:01Z</CreateDate><OriginatorReferenceIdentifier>6000484</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_6000484</OriginatorSystemIdentifier><PackageIdentifier>70905</PackageIdentifier><VersionIdentifier>9</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70905</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-10T11:23:52Z</CreateDate><OriginatorReferenceIdentifier>6000484</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_6000484</OriginatorSystemIdentifier><PackageIdentifier>70898</PackageIdentifier><VersionIdentifier>8</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70898</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-10T09:49:38Z</CreateDate><OriginatorReferenceIdentifier>6000484</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_6000484</OriginatorSystemIdentifier><PackageIdentifier>70883</PackageIdentifier><VersionIdentifier>7</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70883</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-10T09:46:21Z</CreateDate><OriginatorReferenceIdentifier>6000484</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_6000484</OriginatorSystemIdentifier><PackageIdentifier>70882</PackageIdentifier><VersionIdentifier>6</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70882</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-10T09:41:13Z</CreateDate><OriginatorReferenceIdentifier>6000484</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_6000484</OriginatorSystemIdentifier><PackageIdentifier>70881</PackageIdentifier><VersionIdentifier>5</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70881</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-10T09:23:10Z</CreateDate><OriginatorReferenceIdentifier>6000484</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_6000484</OriginatorSystemIdentifier><PackageIdentifier>70878</PackageIdentifier><VersionIdentifier>4</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70878</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-10T08:50:00Z</CreateDate><OriginatorReferenceIdentifier>6000484</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_6000484</OriginatorSystemIdentifier><PackageIdentifier>70874</PackageIdentifier><VersionIdentifier>3</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70874</PackageURL></PackageListing><PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\"><CreateDate>2016-02-10T08:22:35Z</CreateDate><OriginatorReferenceIdentifier>6000484</OriginatorReferenceIdentifier><OriginatorSystemIdentifier>534672_6000484</OriginatorSystemIdentifier><PackageIdentifier>70866</PackageIdentifier><VersionIdentifier>2</VersionIdentifier><PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70866</PackageURL></PackageListing></PackageListings></PackageResponse></DocMagicESignResponse>"
    end

    def message_with_auth_failure
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
      "<DocMagicESignResponse xmlns=\"http://www.docmagic.com/2011/schemas\" status=\"Fail\">" +
      "<Messages>" + 
      "<Message categoryType=\"Server\" messageType=\"Error\">Authentication Failure</Message>" +
      "</Messages>" +
      "</DocMagicESignResponse>"
    end

    def message_with_single_package
      "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
      "<DocMagicESignResponse xmlns=\"http://www.docmagic.com/2011/schemas\" status=\"Success\">" +
      "<PackageResponse>" +
      "<PackageListings>" +
      "<PackageListing packageType=\"Predisclosure\" RESPAStatusType=\"Consented\" packageStatusType=\"InProgress\">" +
      "<CreateDate>2016-02-11T06:05:41Z</CreateDate>" +
      "<OriginatorReferenceIdentifier>6000484</OriginatorReferenceIdentifier>" +
      "<OriginatorSystemIdentifier>534672_6000484</OriginatorSystemIdentifier>" +
      "<PackageIdentifier>70976</PackageIdentifier>" +
      "<VersionIdentifier>25</VersionIdentifier>" +
      "<PackageURL>https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70976</PackageURL>" +
      "</PackageListing>" +
      "</PackageListings>" +
      "</PackageResponse>" +
      "</DocMagicESignResponse>"
    end
  end

  context "filtered on date range" do

    context ".url" do

      it ".for_date_range" do
        sd = "2015-03-23T06:00:000".to_time
        fd = "2015-03-27T18:00:000".to_time
        request = DocMagic::EventListingRequest.for_date_range sd, fd
        expect(request.url).to eq "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/2015-03-23,2015-03-27"
      end

      it ".for_date" do
        sd = "2015-03-23T06:00:000".to_time
        request = DocMagic::EventListingRequest.for_date sd
        expect(request.url).to eq "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/2015-03-23,2015-03-23"
      end

    end

  end

  context "filtered on loan number" do

    context ".url" do

      it "should include the loan number" do
        loan_num = "689372324"
        request = DocMagic::EventListingRequest.for_loan_num loan_num
        expect(request.url).to eq "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/search?OriginatorReferenceIdentifier=#{loan_num}"
      end

    end

  end

  context "unfiltered list" do 

    context ".url" do

      it "should go to the package listings" do
        expect(subject.url).to eq "https://stage-www.docmagic.com/webservices/esign/api/v2/packages"
      end

    end

  end
  
end