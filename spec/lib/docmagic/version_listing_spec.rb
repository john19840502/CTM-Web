require 'spec_helper'
require 'docmagic'

describe DocMagic::VersionListing do

  context ".initialize" do

    it "should read version from hash" do
      version = DocMagic::VersionListing.new version_hash
      expect(version.respa_status_type).to eq "Consented"
      expect(version.active).to be_falsey
      expect(version.package_status_type).to eq "InProgress"
      expect(version.package_type).to eq "Predisclosure"
      expect(version.signature_enabled).to be_truthy
      expect(version.create_date).to eq "2016-02-17T08:21:14Z".to_time
      expect(version.loan_number).to eq "6000485"
      expect(version.system_id).to eq "534672_6000485"
      expect(version.package_id).to eq "71272"
      expect(version.version_number).to eq 2
      expect(version.package_url).to eq "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71272"
    end

    def version_hash
      { "RESPAStatusType" => "Consented", "activeIndicator" => "false", "packageStatusType" => "InProgress", 
        "packageType" => "Predisclosure", "signatureEnabledIndicator" => "true", 
        "CreateDate" => "2016-02-17T08:21:14Z", "OriginatorReferenceIdentifier" => "6000485",
        "OriginatorSystemIdentifier" => "534672_6000485", "PackageIdentifier" => "71272",
        "VersionIdentifier" => "2",
        "PackageURL" => "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71272"}
    end

  end

end