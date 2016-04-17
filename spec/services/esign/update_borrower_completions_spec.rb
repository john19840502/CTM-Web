require 'spec_helper'

describe Esign::UpdateBorrowerCompletions do

  it "should populate esign detail tables" do
    package_id_1 = 12345678
    package_id_2 = 12345679
    loan_number1 = 6000001
    loan_number2 = 6000002
    Esign::EsignPackageVersion.new( { version_number: 1, external_package_id: package_id_1, 
                                      loan_number: loan_number1, package_type: "Predisclosure",
                                      package_status: "Consented", respa_status: "Unknown",
                                      version_date: "2016-03-17T05:38:24.000-07:00".to_time } ).save
    Esign::EsignPackageVersion.new( { version_number: 1, external_package_id: package_id_2, 
                                      loan_number: loan_number2, package_type: "Predisclosure",
                                      package_status: "InProgress", respa_status: "Consented",
                                      version_date: "2016-03-17T05:37:08.000-07:00".to_time } ).save
    
    master_loan = double
    borrower1 = OpenStruct.new
    borrower1.first_name = "TEST"
    borrower1.last_name = "SIGNER"
    borrowers = [borrower1]
    request1 = double
    request2 = double
    allow(DocMagic::EventDetailRequest).to receive(:new).with(package_id_1).and_return request1
    allow(DocMagic::EventDetailRequest).to receive(:new).with(package_id_2).and_return request2
    allow(request1).to receive(:execute).and_return response_json_not_esign(package_id_1, loan_number1)
    allow(request2).to receive(:execute).and_return response_json_esign(package_id_2, loan_number2)
    allow(Master::Loan).to receive(:find_by_loan_num).with("#{loan_number2}").and_return(master_loan)
    allow(master_loan).to receive(:borrowers).and_return(borrowers)
    
    Esign::UpdateBorrowerCompletions.call

    completion_records = Esign::EsignBorrowerCompletion.all
    expect(completion_records.size).to eq 1
    expect(completion_records.first.loan_number).to eq loan_number2
    expect(completion_records.first.esign_signer.external_signer_id).to eq "S_130161"
    
    signer_records = Esign::EsignSigner.all
    expect(signer_records.size).to eq 4
    expect(signer_records[0].external_signer_id).to eq "S_130161"
    expect(signer_records[1].external_signer_id).to eq "S_130162"
    expect(signer_records[2].external_signer_id).to eq "S_130163"
    expect(signer_records[3].external_signer_id).to eq "S_130164"

    document_records = Esign::EsignDocument.all
    expect(document_records.size).to eq 2
    expect(document_records[0].external_document_id).to eq "1205296"
    expect(document_records[1].external_document_id).to eq "1205297"

    line_records = Esign::EsignSignatureLine.all
    expect(line_records.size).to eq 4
    expect(line_records[0].esign_document.external_document_id).to eq "1205297"
    expect(line_records[0].esign_signer).to be_nil
    expect(line_records[1].esign_document.external_document_id).to eq "1205297"
    expect(line_records[1].esign_signer.external_signer_id).to eq "S_130161"
    expect(line_records[2].esign_document.external_document_id).to eq "1205297"
    expect(line_records[2].esign_signer).to be_nil
    expect(line_records[3].esign_document.external_document_id).to eq "1205297"
    expect(line_records[3].esign_signer).to be_nil

    event_records = Esign::EsignSignerEvent.all
    expect(event_records.size).to eq 2
    expect(event_records[0].esign_signer.external_signer_id).to eq "S_130161"
    expect(event_records[0].event_type).to eq "ViewPackage"
    expect(event_records[1].esign_signer.external_signer_id).to eq "S_130161"
    expect(event_records[1].event_type).to eq "CompleteEsign"

    versions = Esign::EsignPackageVersion.all
    expect(versions.size).to eq 2
    expect(versions[0].esign_enabled).to be_falsey
    expect(versions[1].esign_enabled).to be_truthy
  end

  it "should ignore processed package versions" do
    package_id = 12345679
    loan_number = 6000002
    processed_date = "2016-03-19T07:12:52.000-07:00".to_time
    Esign::EsignPackageVersion.new( { version_number: 1, external_package_id: package_id, 
                                      loan_number: loan_number, package_type: "Predisclosure",
                                      package_status: "InProgress", respa_status: "Consented",
                                      version_date: "2016-03-17T05:37:08.000-07:00".to_time,
                                      esign_enabled: true, 
                                      processed_date: processed_date } ).save

    allow(DocMagic::EventDetailRequest).to receive(:new).and_raise "There should not be any calls to DocMagic"

    Esign::UpdateBorrowerCompletions.call

    expect(Esign::EsignBorrowerCompletion.all).to be_empty
    expect(Esign::EsignSigner.all).to be_empty
    expect(Esign::EsignDocument.all).to be_empty
    expect(Esign::EsignSignatureLine.all).to be_empty
    expect(Esign::EsignSignerEvent.all).to be_empty
    version_records = Esign::EsignPackageVersion.all
    expect(version_records.size).to eq 1
    expect(version_records[0].processed_date).to eq processed_date
  end

  it "should handle system user" do
    package_id = 12345679
    loan_number = 6000002
    Esign::EsignPackageVersion.new( { version_number: 1, external_package_id: package_id, 
                                      loan_number: loan_number, package_type: "Predisclosure",
                                      package_status: "InProgress", respa_status: "Consented",
                                      version_date: "2016-03-17T05:37:08.000-07:00".to_time } ).save
    master_loan = double
    borrower1 = OpenStruct.new
    borrower1.first_name = "TEST"
    borrower1.last_name = "SIGNER"
    borrowers = [borrower1]
    request = double
    allow(DocMagic::EventDetailRequest).to receive(:new).with(package_id).and_return request
    response = response_json_esign(package_id, loan_number)
    response.events << event("CreatePackage", "2016-03-02T12:00:10.000-08:00".to_time, "eSign event created", "System User", nil, nil)
    allow(request).to receive(:execute).and_return response
    allow(Master::Loan).to receive(:find_by_loan_num).with("#{loan_number}").and_return(master_loan)
    allow(master_loan).to receive(:borrowers).and_return(borrowers)
    
    Esign::UpdateBorrowerCompletions.call

    event_records = Esign::EsignSignerEvent.all
    expect(event_records.size).to eq 3
    expect(event_records[2].esign_signer).to be_nil
    expect(event_records[2].event_type).to eq "CreatePackage"
  end

  it "should handle signers that haven't consented yet" do
    package_id = 12345679
    loan_number = 6000002
    master_loan = double
    Esign::EsignPackageVersion.new( { version_number: 1, external_package_id: package_id, 
                                      loan_number: loan_number, package_type: "Predisclosure",
                                      package_status: "InProgress", respa_status: "Consented",
                                      version_date: "2016-03-17T05:37:08.000-07:00".to_time } ).save

    master_loan = double
    borrower1 = OpenStruct.new
    borrower1.first_name = "TEST"
    borrower1.last_name = "SIGNER"
    borrowers = [borrower1]
    request = double
    response = response_json_esign(package_id, loan_number)
    response.signer_actions.delete_if{|sa| sa.completed_date.nil?}
    allow(DocMagic::EventDetailRequest).to receive(:new).with(package_id).and_return request
    allow(request).to receive(:execute).and_return response
    allow(Master::Loan).to receive(:find_by_loan_num).with("#{loan_number}").and_return(master_loan)
    allow(master_loan).to receive(:borrowers).and_return(borrowers)
    
    Esign::UpdateBorrowerCompletions.call

    expect(Esign::EsignBorrowerCompletion.all.size).to eq 1
    expect(Esign::EsignSigner.all.size).to eq 4
  end

  it "should only create queue entry for borrowers" do
    package_id = 12345679
    loan_number = 6000002
    master_loan = double
    Esign::EsignPackageVersion.new( { version_number: 1, external_package_id: package_id, 
                                      loan_number: loan_number, package_type: "Predisclosure",
                                      package_status: "InProgress", respa_status: "Consented",
                                      version_date: "2016-03-17T05:37:08.000-07:00".to_time } ).save
    master_loan = double
    borrower1 = OpenStruct.new
    borrower1.first_name = "TEST"
    borrower1.last_name = "SIGNER"
    borrowers = [borrower1]
    request = double
    allow(DocMagic::EventDetailRequest).to receive(:new).with(package_id).and_return request
    allow(request).to receive(:execute).and_return response_json_esign_lo_complete(package_id, loan_number)
    allow(Master::Loan).to receive(:find_by_loan_num).with("#{loan_number}").and_return(master_loan)
    allow(master_loan).to receive(:borrowers).and_return(borrowers)
    
    Esign::UpdateBorrowerCompletions.call

    completion_records = Esign::EsignBorrowerCompletion.all
    expect(completion_records.size).to eq 1
    expect(completion_records.first.loan_number).to eq loan_number
    expect(completion_records.first.esign_signer.external_signer_id).to eq "S_130161"
  end

  it "should not create duplicate entries" do
    package_id_1 = 12345678
    loan_number = 6000001
    Esign::EsignPackageVersion.new( { version_number: 1, external_package_id: package_id_1, 
                                      loan_number: loan_number, package_type: "Predisclosure",
                                      package_status: "Consented", respa_status: "Unknown",
                                      version_date: "2016-03-17T05:38:24.000-07:00".to_time } ).save
    
    master_loan = double
    borrower1 = OpenStruct.new
    borrower1.first_name = "TEST"
    borrower1.last_name = "SIGNER"
    borrowers = [borrower1]
    request1 = double

    allow(DocMagic::EventDetailRequest).to receive(:new).with(package_id_1).and_return request1
    allow(request1).to receive(:execute).and_return response_json_esign(package_id_1, loan_number)
    allow(Master::Loan).to receive(:find_by_loan_num).with("#{loan_number}").and_return(master_loan)
    allow(master_loan).to receive(:borrowers).and_return(borrowers)    
    
    # insert pre-existing records
    Esign::UpdateBorrowerCompletions.call

    package_id_2 = 12345679
    Esign::EsignPackageVersion.new( { version_number: 2, external_package_id: package_id_2, 
                                      loan_number: loan_number, package_type: "Predisclosure",
                                      package_status: "InProgress", respa_status: "Consented",
                                      version_date: "2016-03-17T05:37:08.000-07:00".to_time } ).save
    
    request2 = double
    allow(DocMagic::EventDetailRequest).to receive(:new).with(package_id_2).and_return request2    
    allow(request2).to receive(:execute).and_return response_json_esign(package_id_2, loan_number)

    Esign::UpdateBorrowerCompletions.call

    completion_records = Esign::EsignBorrowerCompletion.all
    expect(completion_records.size).to eq 1
    expect(completion_records.first.loan_number).to eq loan_number
    expect(completion_records.first.esign_signer.external_signer_id).to eq "S_130161"
    
    signer_records = Esign::EsignSigner.all
    expect(signer_records.size).to eq 4
    expect(signer_records[0].external_signer_id).to eq "S_130161"
    expect(signer_records[1].external_signer_id).to eq "S_130162"
    expect(signer_records[2].external_signer_id).to eq "S_130163"
    expect(signer_records[3].external_signer_id).to eq "S_130164"

    document_records = Esign::EsignDocument.all
    expect(document_records.size).to eq 2
    expect(document_records[0].external_document_id).to eq "1205296"
    expect(document_records[1].external_document_id).to eq "1205297"

    line_records = Esign::EsignSignatureLine.all
    expect(line_records.size).to eq 4
    expect(line_records[0].esign_document.external_document_id).to eq "1205297"
    expect(line_records[0].esign_signer).to be_nil
    expect(line_records[1].esign_document.external_document_id).to eq "1205297"
    expect(line_records[1].esign_signer.external_signer_id).to eq "S_130161"
    expect(line_records[2].esign_document.external_document_id).to eq "1205297"
    expect(line_records[2].esign_signer).to be_nil
    expect(line_records[3].esign_document.external_document_id).to eq "1205297"
    expect(line_records[3].esign_signer).to be_nil

    event_records = Esign::EsignSignerEvent.all
    expect(event_records.size).to eq 2
    expect(event_records[0].esign_signer.external_signer_id).to eq "S_130161"
    expect(event_records[0].event_type).to eq "ViewPackage"
    expect(event_records[1].esign_signer.external_signer_id).to eq "S_130161"
    expect(event_records[1].event_type).to eq "CompleteEsign"

    versions = Esign::EsignPackageVersion.all
    expect(versions.size).to eq 2
    expect(versions[0].esign_enabled).to be_truthy
    expect(versions[1].esign_enabled).to be_truthy
  end

  it "should update records" do
    package_id_1 = 12345678
    loan_number = 6000001
    Esign::EsignPackageVersion.new( { version_number: 1, external_package_id: package_id_1, 
                                      loan_number: loan_number, package_type: "Predisclosure",
                                      package_status: "Consented", respa_status: "Unknown",
                                      version_date: "2016-03-17T05:38:24.000-07:00".to_time } ).save
    
    master_loan = double
    borrower1 = OpenStruct.new
    borrower1.first_name = "TEST"
    borrower1.last_name = "SIGNER"
    borrower2 = OpenStruct.new
    borrower2.first_name = "FAKE"
    borrower2.last_name = "SIGNER"
    borrowers = [borrower1, borrower2]
    request1 = double
    allow(DocMagic::EventDetailRequest).to receive(:new).with(package_id_1).and_return request1
    allow(request1).to receive(:execute).and_return response_json_esign(package_id_1, loan_number)
    allow(Master::Loan).to receive(:find_by_loan_num).with("#{loan_number}").and_return(master_loan)
    allow(master_loan).to receive(:borrowers).and_return(borrowers)    
    
    # insert pre-existing records
    Esign::UpdateBorrowerCompletions.call

    package_id_2 = 12345679
    Esign::EsignPackageVersion.new( { version_number: 2, external_package_id: package_id_2, 
                                      loan_number: loan_number, package_type: "Predisclosure",
                                      package_status: "InProgress", respa_status: "Consented",
                                      version_date: "2016-03-17T05:37:08.000-07:00".to_time } ).save
    
    request2 = double
    response2 = response_json_esign(package_id_2, loan_number)
    mark = response2.listings[1].document_marks.last
    mark.signer_id = "S_130162"
    mark.mark_type = "Initial"
    response2.events << event("CompleteEsign", "2016-03-19T06:13:40.000-07:00".to_time, "eSign event signing complete", "Fake Signer", nil, "64.9.216.173")
    signer_action = response2.signer_actions.select{|sa| sa.signer_id == "S_130162"}.first
    signer_action.completed_date = "2016-03-19T06:13:40.000-07:00".to_time
    allow(DocMagic::EventDetailRequest).to receive(:new).with(package_id_2).and_return request2    
    allow(request2).to receive(:execute).and_return response2

    Esign::UpdateBorrowerCompletions.call

    completion_records = Esign::EsignBorrowerCompletion.all
    expect(completion_records.size).to eq 2
    expect(completion_records.first.loan_number).to eq loan_number
    expect(completion_records.first.esign_signer.external_signer_id).to eq "S_130161"
    expect(completion_records.last.loan_number).to eq loan_number
    expect(completion_records.last.esign_signer.external_signer_id).to eq "S_130162"
    
    signer_records = Esign::EsignSigner.all
    expect(signer_records.size).to eq 4
    expect(signer_records[0].external_signer_id).to eq "S_130161"
    expect(signer_records[1].external_signer_id).to eq "S_130162"
    expect(signer_records[2].external_signer_id).to eq "S_130163"
    expect(signer_records[3].external_signer_id).to eq "S_130164"

    document_records = Esign::EsignDocument.all
    expect(document_records.size).to eq 2
    expect(document_records[0].external_document_id).to eq "1205296"
    expect(document_records[1].external_document_id).to eq "1205297"

    line_records = Esign::EsignSignatureLine.all
    expect(line_records.size).to eq 4
    expect(line_records[0].esign_document.external_document_id).to eq "1205297"
    expect(line_records[0].esign_signer).to be_nil
    expect(line_records[1].esign_document.external_document_id).to eq "1205297"
    expect(line_records[1].esign_signer.external_signer_id).to eq "S_130161"
    expect(line_records[2].esign_document.external_document_id).to eq "1205297"
    expect(line_records[2].esign_signer).to be_nil
    expect(line_records[3].esign_document.external_document_id).to eq "1205297"
    expect(line_records[3].esign_signer.external_signer_id).to eq "S_130162"

    event_records = Esign::EsignSignerEvent.all
    expect(event_records.size).to eq 3
    expect(event_records[0].esign_signer.external_signer_id).to eq "S_130161"
    expect(event_records[0].event_type).to eq "ViewPackage"
    expect(event_records[1].esign_signer.external_signer_id).to eq "S_130161"
    expect(event_records[1].event_type).to eq "CompleteEsign"
    expect(event_records[2].esign_signer.external_signer_id).to eq "S_130162"
    expect(event_records[2].event_type).to eq "CompleteEsign"

    versions = Esign::EsignPackageVersion.all
    expect(versions.size).to eq 2
    expect(versions[0].esign_enabled).to be_truthy
    expect(versions[1].esign_enabled).to be_truthy
  end

  it "should handle failed response gracefully" do
    package_id_1 = 12345678
    package_id_2 = 12345679
    loan_number1 = 6000001
    loan_number2 = 6000002
    Esign::EsignPackageVersion.new( { version_number: 1, external_package_id: package_id_1, 
                                      loan_number: loan_number1, package_type: "Predisclosure",
                                      package_status: "Consented", respa_status: "Unknown",
                                      version_date: "2016-03-17T05:38:24.000-07:00".to_time } ).save
    Esign::EsignPackageVersion.new( { version_number: 1, external_package_id: package_id_2, 
                                      loan_number: loan_number2, package_type: "Predisclosure",
                                      package_status: "InProgress", respa_status: "Consented",
                                      version_date: "2016-03-17T05:37:08.000-07:00".to_time } ).save
    
    master_loan = double
    borrower1 = OpenStruct.new
    borrower1.first_name = "TEST"
    borrower1.last_name = "SIGNER"
    borrowers = [borrower1]
    request1 = double
    request2 = double
    allow(DocMagic::EventDetailRequest).to receive(:new).with(package_id_1).and_return request1
    allow(DocMagic::EventDetailRequest).to receive(:new).with(package_id_2).and_return request2
    allow(request1).to receive(:execute).and_return response_failure
    allow(request2).to receive(:execute).and_return response_json_esign(package_id_2, loan_number2)
    allow(Master::Loan).to receive(:find_by_loan_num).with("#{loan_number2}").and_return(master_loan)
    allow(master_loan).to receive(:borrowers).and_return(borrowers)
    
    Esign::UpdateBorrowerCompletions.call

    completion_records = Esign::EsignBorrowerCompletion.all
    expect(completion_records.size).to eq 1
    expect(completion_records.first.loan_number).to eq loan_number2
    expect(completion_records.first.esign_signer.external_signer_id).to eq "S_130161"
    
    signer_records = Esign::EsignSigner.all
    expect(signer_records.size).to eq 4
    expect(signer_records[0].external_signer_id).to eq "S_130161"
    expect(signer_records[1].external_signer_id).to eq "S_130162"
    expect(signer_records[2].external_signer_id).to eq "S_130163"
    expect(signer_records[3].external_signer_id).to eq "S_130164"

    document_records = Esign::EsignDocument.all
    expect(document_records.size).to eq 2
    expect(document_records[0].external_document_id).to eq "1205296"
    expect(document_records[1].external_document_id).to eq "1205297"

    line_records = Esign::EsignSignatureLine.all
    expect(line_records.size).to eq 4
    expect(line_records[0].esign_document.external_document_id).to eq "1205297"
    expect(line_records[0].esign_signer).to be_nil
    expect(line_records[1].esign_document.external_document_id).to eq "1205297"
    expect(line_records[1].esign_signer.external_signer_id).to eq "S_130161"
    expect(line_records[2].esign_document.external_document_id).to eq "1205297"
    expect(line_records[2].esign_signer).to be_nil
    expect(line_records[3].esign_document.external_document_id).to eq "1205297"
    expect(line_records[3].esign_signer).to be_nil

    event_records = Esign::EsignSignerEvent.all
    expect(event_records.size).to eq 2
    expect(event_records[0].esign_signer.external_signer_id).to eq "S_130161"
    expect(event_records[0].event_type).to eq "ViewPackage"
    expect(event_records[1].esign_signer.external_signer_id).to eq "S_130161"
    expect(event_records[1].event_type).to eq "CompleteEsign"

    versions = Esign::EsignPackageVersion.all
    expect(versions.size).to eq 2
    expect(versions[0].esign_enabled).to be_nil
    expect(versions[1].esign_enabled).to be_truthy
  end

  def response_failure
    response = OpenStruct.new
    response.success = false
    response.messages = []
    response.messages << "Big bada-boom!"
    response.package_info = nil
    response.listings = []
    response.events = []
    response.signer_actions = []
    response.signers = []
    response.versions = []
    response
  end

  def response_json_not_esign package_id, loan_number
    response = OpenStruct.new
    response.success = true
    response.messages = []
    response.package_info = package_info "Predisclosure", "InProgress", "Consented", false, "2016-02-23".to_time, "2016-03-17T05:38:24.000-07:00".to_time, loan_number, "534672_6000001", package_id, "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/#{package_id}/documents", 1 
    response.listings = []
    response.listings << document_listing("INITIAL DISCLOSURE COVER LETTER", "1205294", "idcl3.cst.xml", 1, [])
    marks = []
    marks << document_mark("2325426", "", "", 3)
    marks << document_mark("2325424", "", "", 3)
    marks << document_mark("2325427", "", "", 3)
    marks << document_mark("2325425", "", "", 3)
    response.listings << document_listing("ESIGN DISCLOSURE AND CONSENT", "1205295", "esdc.msc.xml", 3, marks)
    response.events = []
    response.events << event("NoteToSender", "2016-03-02T12:41:10.000-08:00".to_time, "eSign Event Note to Sender", "System User", "Reminder sent to disclosureteam@mbmortgage.com (eSign Reminder [Loan Number: #{loan_number}])", nil)
    response.events << event("DeliverReport", "2016-03-02T12:41:10.000-08:00".to_time, "eSign Event Report delivered", "System User", "Log1 sent to disclosureteam@mbmortgage.com (eSign Action Log [Loan Number: #{loan_number}])", nil)
    response.signer_actions = []
    response.signers = []
    response.signers << signer("S_130157", "borrower1@foo.com", "Test", "Borrower", "Test Borrower", "ahb8766872")
    response.signers << signer("S_130158", "borrower2@foo.com", "Fake", "Borrower", "Fake Borrower", "qw3rghi69w")
    response.signers << signer("S_130159", "borrower3@foo.com", "Bogus", "Borrower", "Bogus Borrower", "sh762hldsa")
    response.signers << signer("S_130160", "borrower4@foo.com", "Loan", "Officer", "Loan Officer", "hrwa9p3298")
    response.versions = []
    response
  end

  def response_json_esign package_id, loan_number
    response = OpenStruct.new
    response.success = true
    response.messages = []
    response.package_info = package_info "Predisclosure", "InProgress", "Consented", true, "2016-02-24".to_time, "2016-03-17T05:37:08.000-07:00".to_time, "#{loan_number}", "534672_#{loan_number}", package_id, "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/#{package_id}/documents", 2
    response.listings = []
    response.listings << document_listing("INITIAL DISCLOSURE COVER LETTER", "1205296", "idcl3.cst.xml", 1, [])
    marks = []
    marks << document_mark("2325430", "", "", 3)
    marks << document_mark("2325428", "Signature", "S_130161", 3)
    marks << document_mark("2325431", "", "", 3)
    marks << document_mark("2325429", "", "", 3)
    response.listings << document_listing("ESIGN DISCLOSURE AND CONSENT", "1205297", "esdc.msc.xml", 3, marks)
    response.events = []
    response.events << event("ViewPackage", "2016-03-17T05:46:51.000-07:00".to_time, "eSign Viewing Code validation successful", "Test Signer", "Disclosure version 10 prepared on March 17, 2016, 5:37 am PDT displayed", "64.9.216.172")
    response.events << event("CompleteEsign", "2016-03-17T05:54:40.000-07:00".to_time, "eSign event signing complete", "Test Signer", nil, "64.9.216.172")
    response.signer_actions = []
    response.signer_actions << signer_action("S_130161", "130161", "2016-03-15T13:25:46.000-05:00".to_time, "2016-03-17T07:46:45.000-05:00".to_time, "2016-03-17T07:54:40.000-05:00".to_time)
    response.signer_actions << signer_action("S_130162", "130162", "2016-03-15T13:25:46.000-05:00".to_time, "2016-03-17T07:46:45.000-05:00".to_time, nil)
    response.signer_actions << signer_action("S_130163", "130163", nil, nil, nil)
    response.signer_actions << signer_action("S_130164", "130164", "2016-03-15T13:25:46.000-05:00".to_time, nil, nil)
    response.signers = []
    response.signers << signer("S_130161", "signer1@foo.com", "Test", "Signer", "Test Signer", "alkjsdhf875")
    response.signers << signer("S_130162", "signer2@foo.com", "Fake", "Signer", "Fake Signer", "jakhi74t38f")
    response.signers << signer("S_130163", "signer3@foo.com", "Bogus", "Signer", "Bogus Signer", "aie3086asd")
    response.signers << signer("S_130164", "signer4@foo.com", "Loan", "Officer", "Loan Officer", "hiu6786jah")
    response.versions = []
    response.versions << version("Consented", false, "InProgress", "Predisclosure", true, "2016-03-15T11:24:21Z".to_time, loan_number, package_id, 1)
    response.versions << version("Consented", true, "InProgress", "Predisclosure", true, "2016-03-15T11:54:57Z".to_time, loan_number, package_id, 2)
    response
  end

  def response_json_esign_lo_complete package_id, loan_number
    response = OpenStruct.new
    response.success = true
    response.messages = []
    response.package_info = package_info "Predisclosure", "InProgress", "Consented", true, "2016-02-24".to_time, "2016-03-17T05:37:08.000-07:00".to_time, "#{loan_number}", "534672_#{loan_number}", package_id, "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/#{package_id}/documents", 2
    response.listings = []
    response.listings << document_listing("INITIAL DISCLOSURE COVER LETTER", "1205296", "idcl3.cst.xml", 1, [])
    marks = []
    marks << document_mark("2325428", "Signature", "S_130161", 3)
    marks << document_mark("2325429", "Signature", "S_130162", 3)
    response.listings << document_listing("ESIGN DISCLOSURE AND CONSENT", "1205297", "esdc.msc.xml", 3, marks)
    response.events = []
    response.events << event("ViewPackage", "2016-03-17T05:46:51.000-07:00".to_time, "eSign Viewing Code validation successful", "Test Signer", "Disclosure version 10 prepared on March 17, 2016, 5:37 am PDT displayed", "64.9.216.172")
    response.events << event("CompleteEsign", "2016-03-17T05:54:40.000-07:00".to_time, "eSign event signing complete", "Test Signer", nil, "64.9.216.172")
    response.signer_actions = []
    response.signer_actions << signer_action("S_130161", "130161", "2016-03-15T13:25:46.000-05:00".to_time, "2016-03-17T07:46:45.000-05:00".to_time, "2016-03-17T07:54:40.000-05:00".to_time)
    response.signer_actions << signer_action("S_130162", "130162", "2016-03-15T13:25:46.000-05:00".to_time, "2016-03-17T07:46:45.000-05:00".to_time, "2016-03-17T07:58:40.000-05:00".to_time)
    response.signers = []
    response.signers << signer("S_130161", "signer1@foo.com", "Test", "Signer", "Test Signer", "alkjsdhf875")
    response.signers << signer("S_130162", "signer2@foo.com", "Loan", "Officer", "Loan Officer", "jakhi74t38f")
    response.versions = []
    response.versions << version("Consented", false, "InProgress", "Predisclosure", true, "2016-03-15T11:24:21Z".to_time, loan_number, package_id, 1)
    response.versions << version("Consented", true, "InProgress", "Predisclosure", true, "2016-03-15T11:54:57Z".to_time, loan_number, package_id, 2)
    response
  end

  def version respa_status_type, active, package_status_type, package_type, signature_enabled, create_date, loan_number, package_id, version_number
    v = OpenStruct.new
    v.respa_status_type = respa_status_type
    v.active = active
    v.package_status_type = package_status_type
    v.package_type = package_type
    v.signature_enabled = signature_enabled
    v.create_date = create_date
    v.loan_number = loan_number
    v.system_id = "534672_#{loan_number}"
    v.package_id = package_id
    v.version_number = version_number
    v.package_url = "https://stage-www.docmagic.com/webservices/esign/api/v2/packages/#{package_id}"
    v
  end

  def signer signer_id, email, first_name, last_name, full_name, token_id
    s = OpenStruct.new
    s.signer_id = signer_id
    s.email = email
    s.first_name = first_name
    s.last_name = last_name
    s.full_name = full_name
    s.token_id = token_id
    s.verification_irs_4506_uri = "/webservices/esign/api/v2/packages/72359/signers/#{signer_id}/verifications/IRS4506"
    s.uri = "/webservices/esign/api/v2/packages/72359/signers/#{signer_id}"
    s
  end

  def event event_type, event_date, event_type_description, user_full_name, note_description, user_ip_address
    ev = OpenStruct.new
    ev.event_type = event_type
    ev.event_date = event_date
    ev.event_type_description = event_type_description
    ev.user_full_name = user_full_name
    ev.note_description = note_description
    ev.user_ip_address = user_ip_address
    ev
  end

  def signer_action signer_id, signer_id_number, consent_approved_date, start_date, completed_date
    action = OpenStruct.new
    action.signer_id = signer_id
    action.signer_id_number = signer_id_number
    action.consent_approved_date = consent_approved_date
    action.start_date = start_date
    action.completed_date = completed_date
    action
  end

  def document_mark mark_id, mark_type, signer_id, page_number_count
    mark = OpenStruct.new
    mark.mark_id = mark_id
    mark.mark_type = mark_type
    mark.signer_id = signer_id
    mark.page_number_count = page_number_count
    mark
  end

  def document_listing description, document_id, document_name, total_page_count, document_marks
    listing = OpenStruct.new
    listing.description = description
    listing.document_id = document_id
    listing.document_name = document_name
    listing.document_marks = document_marks
    listing.total_page_count = total_page_count
    listing
  end

  def package_info package_type, package_status_type, respa_status_type, signature_enabled, application_date, create_date, loan_number, system_id, package_id, package_url, version_id
    info = OpenStruct.new
    info.package_type = package_type
    info.package_status_type = package_status_type
    info.respa_status_type = respa_status_type
    info.signature_enabled = signature_enabled
    info.application_date = application_date
    info.create_date = create_date
    info.loan_number = loan_number
    info.system_id = system_id
    info.package_id = package_id
    info.package_url = package_url
    info.version_id = version_id
    info
  end

end