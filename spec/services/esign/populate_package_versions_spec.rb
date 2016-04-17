require 'spec_helper'

describe Esign::PopulatePackageVersions do

  it "should create package versions from listings" do
    request = double
    allow(DocMagic::EventListingRequest).to receive(:new).and_return request
    allow(request).to receive(:execute).and_return response_json

    Esign::PopulatePackageVersions.call

    records = Esign::EsignPackageVersion.all
    expect(records.size).to eq 2
    expect(records[0].loan_number).to eq 6000001
    expect(records[0].external_package_id).to eq 12345678
    expect(records[1].loan_number).to eq 6000002
    expect(records[1].external_package_id).to eq 12345679
  end

  it "should skip package versions that are already listed" do
    # duplicate of 2nd listing
    existing_record = Esign::EsignPackageVersion.new( {version_number: 2, external_package_id: "12345679",
                                                      loan_number: 6000002, package_type: "Standard",
                                                      package_status: "InProgress", respa_status: "Unknown",
                                                      version_date: "2016-01-05T15:41:17Z".to_time} )
    existing_record.save

    request = double
    allow(DocMagic::EventListingRequest).to receive(:new).and_return request
    allow(request).to receive(:execute).and_return response_json

    Esign::PopulatePackageVersions.call

    records = Esign::EsignPackageVersion.all
    expect(records.size).to eq 2
    expect(records[0].loan_number).to eq 6000002
    expect(records[1].loan_number).to eq 6000001
  end

  it "should handle unsuccessful response" do
    response = OpenStruct.new
    response.success = false
    response.messages = ["Authentication Failure"]
    response.listings = []

    request = double
    allow(DocMagic::EventListingRequest).to receive(:new).and_return request
    allow(request).to receive(:execute).and_return response

    Esign::PopulatePackageVersions.call

    records = Esign::EsignPackageVersion.all
    expect(records.size).to eq 0
  end

  def response_json
    response = OpenStruct.new
    response.success = true
    response.messages = []
    response.listings = [
      OpenStruct.new( package_type: "IntegratedDisclosure", package_status_type: "Reviewed", respa_status_type: "Consented",
                      signature_enabled: nil, application_date: nil, create_date: "2016-01-05T17:24:55Z".to_time,
                      loan_number: "6000001", system_id: "534672_6000001", package_id: "12345678",
                      package_url: "https://www.docmagic.com/webservices/esign/api/v1/packages/12345678",
                      version_id: 1),
      OpenStruct.new( package_type: "Standard", package_status_type: "InProgress", respa_status_type: "Unknown",
                      signature_enabled: nil, application_date: nil, create_date: "2016-01-05T15:41:17Z".to_time,
                      loan_number: "6000002", system_id: "534672_6000002", package_id: "12345679",
                      package_url: "https://www.docmagic.com/webservices/esign/api/v1/packages/12345679",
                      version_id: 2)
    ]
    response
  end

  # error conditions?

end