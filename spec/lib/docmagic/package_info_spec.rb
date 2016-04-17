require 'spec_helper'
require 'docmagic'

describe DocMagic::PackageInfo do

  context ".initialize" do

    it "should populate from event detail hash" do
      hash = {"packageType" => "Predisclosure", "packageStatusType" => "InProgress", 
              "RESPAStatusType" => "Consented", "signatureEnabledIndicator" => "true", 
              "ApplicationDate" => "2016-02-15", "CreateDate" => "2016-02-15T07:57:16.000-08:00", 
              "OriginatorReferenceIdentifier" => "1000648", 
              "OriginatorSystemIdentifier" => "534672_1000648", 
              "PackageIdentifier" => "71128", "VersionIdentifier" => "1", 
              "DocumentListings" => {"DocumentPackageURL" => "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71128/documents"}}
      info = DocMagic::PackageInfo.new hash
      expect(info.package_type).to eq "Predisclosure"
      expect(info.package_status_type).to eq "InProgress"
      expect(info.respa_status_type).to eq "Consented"
      expect(info.signature_enabled).to be_truthy
      expect(info.application_date).to eq "2016-02-15".to_date
      expect(info.create_date).to eq "2016-02-15T10:57:16.000-05:00".to_time
      expect(info.loan_number).to eq "1000648"
      expect(info.system_id).to eq "534672_1000648"
      expect(info.package_id).to eq "71128"
      expect(info.version_id).to eq 1
      expect(info.package_url).to eq "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/71128/documents"
    end

    it "should populate from event listing hash" do
      hash = {"packageType" => "Predisclosure", "RESPAStatusType" => "Consented", 
              "packageStatusType" => "InProgress", "CreateDate" => "2016-02-11T06:05:41Z", 
              "OriginatorReferenceIdentifier" => "6000484", 
              "OriginatorSystemIdentifier" => "534672_6000484", 
              "PackageIdentifier" => "70976", "VersionIdentifier" => "25", 
              "PackageURL" => "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70976"}
      info = DocMagic::PackageInfo.new hash
      expect(info.package_type).to eq "Predisclosure"
      expect(info.package_status_type).to eq "InProgress"
      expect(info.respa_status_type).to eq "Consented"
      expect(info.signature_enabled).to be_nil
      expect(info.application_date).to be_nil
      expect(info.create_date).to eq "2016-02-11T01:05:41.000-05:00".to_time
      expect(info.loan_number).to eq "6000484"
      expect(info.system_id).to eq "534672_6000484"
      expect(info.package_id).to eq "70976"
      expect(info.version_id).to eq 25
      expect(info.package_url).to eq "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/70976"
    end

  end

end