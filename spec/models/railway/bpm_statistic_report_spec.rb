require 'spec_helper'

describe BpmStatisticReport do

  before do
    Bpm::LoanValidationEvent.delete_all
    Bpm::LoanValidationEventMessage.delete_all
    Bpm::LoanValidationFactType.delete_all
    Bpm::LoanValidationFactTypeValue.delete_all
    Bpm::LoanValidationFlow.delete_all
    Bpm::LoanValidationMessageType.delete_all
  end

  # BpmStatisticReport involves mongo DB, So need to remove these tests
  # it "should be able to find requests by loan number" do
  #   a = Bpm::LoanValidationEvent.create loan_num: '1234567'
  #   b = Bpm::LoanValidationEvent.create loan_num: '2222222'
  #   report = build_report loan_num: '1234567'
  #   report.validation_requests.should include(a)
  #   report.validation_requests.should_not include(b)
  # end

  # it "when loan number is present, ignore other filters" do
  #   a = Bpm::LoanValidationEvent.create loan_num: '1234567', underwriter: 'Fred Flintstone'
  #   b = Bpm::LoanValidationEvent.create loan_num: '1234567', underwriter: 'Barney Rubble'
  #   report = build_report loan_num: '1234567', underwriter: 'Fred Flintstone'
  #   report.validation_requests.should include(a)
  #   report.validation_requests.should include(b)
  # end

  # it "should be able to filter by underwriter name" do
  #   a = Bpm::LoanValidationEvent.create underwriter: 'Fred Flintstone'
  #   b = Bpm::LoanValidationEvent.create underwriter: 'Barney Rubble'
  #   report = build_report underwriter: 'Fred Flintstone'
  #   report.validation_requests.should include(a)
  #   report.validation_requests.should_not include(b)
  # end

  # it "should ignore trailing commas when filtering by underwriter name" do
  #   a = Bpm::LoanValidationEvent.create underwriter: 'Fred Flintstone'
  #   report = build_report underwriter: 'Fred Flintstone, '
  #   report.validation_requests.to_a.should include(a)
  # end

  # it "should be able to search for more than one underwriter" do
  #   a = Bpm::LoanValidationEvent.create underwriter: 'Fred Flintstone'
  #   b = Bpm::LoanValidationEvent.create underwriter: 'Barney Rubble'
  #   c = Bpm::LoanValidationEvent.create underwriter: 'Wilma Flintstone'
  #   report = build_report underwriter: 'Fred Flintstone, Barney Rubble'
  #   report.validation_requests.should include(a)
  #   report.validation_requests.should include(b)
  #   report.validation_requests.should_not include(c)
  # end

  # it "should be able to search for text within validation messages" do
  #   a = Bpm::LoanValidationEvent.create validation_messages: [ make_error('Failed to do stuff') ]
  #   b = Bpm::LoanValidationEvent.create validation_messages: [ make_error('forgot to stuff the turkey') ]
  #   c = Bpm::LoanValidationEvent.create validation_messages: [ make_error('Insufficient staff') ]
  #   d = Bpm::LoanValidationEvent.create validation_messages: [ make_warning('stuff') ]
  #   report = build_report validation_errors: 'stuff'
  #   results = report.validation_requests.to_a
  #   results.should include(a)
  #   results.should include(b)
  #   results.should_not include(c)
  #   results.should include(d)
  # end

  # it "should be able to search more than one validation error message" do
  #   a = Bpm::LoanValidationEvent.create validation_messages: [ make_error('Failed to do stuff') ]
  #   b = Bpm::LoanValidationEvent.create validation_messages: [ make_error('Insufficient staff') ]
  #   report = build_report validation_errors: 'stuff, staff'
  #   results = report.validation_requests.to_a
  #   results.should include(a)
  #   results.should include(b)
  # end

  # it "should ignore trailing commas when searching in validation messages" do
  #   a = Bpm::LoanValidationEvent.create validation_messages: [ make_error('Failed to do stuff') ]
  #   b = Bpm::LoanValidationEvent.create validation_messages: [ make_error('Insufficient staff') ]
  #   c = Bpm::LoanValidationEvent.create validation_messages: [ make_error('foo') ]
  #   report = build_report validation_errors: 'stuff, staff, '
  #   results = report.validation_requests.to_a
  #   results.should include(a)
  #   results.should include(b)
  #   results.should_not include(c)
  # end

  # it "should be able to search by loan status" do
  #   a = Bpm::LoanValidationEvent.create loan_status: 'U/W Submitted'
  #   b = Bpm::LoanValidationEvent.create loan_status: 'U/W Received'
  #   report = build_report loan_status_at_validation: 'U/W Submitted'
  #   report.validation_requests.should include(a)
  #   report.validation_requests.should_not include(b)
  # end

  # it "should be able to search by product code" do
  #   a = Bpm::LoanValidationEvent.create product_code: 'C20FXD'
  #   b = Bpm::LoanValidationEvent.create product_code: 'C30FXD'
  #   report = build_report product_code: 'C20FXD'
  #   report.validation_requests.should include(a)
  #   report.validation_requests.should_not include(b)
  # end

  # it "should be able to search by channel" do
  #   a = Bpm::LoanValidationEvent.create channel: 'A0 Whatever'
  #   b = Bpm::LoanValidationEvent.create channel: 'W0 Wholesale'
  #   report = build_report channel: 'A0 Whatever'
  #   report.validation_requests.should include(a)
  #   report.validation_requests.should_not include(b)
  # end

  # it "should be able to search by region" do
  #   a = Bpm::LoanValidationEvent.create property_state: 'MI'
  #   b = Bpm::LoanValidationEvent.create property_state: 'FL'
  #   report = build_report region: 'NE/Midwest'
  #   report.validation_requests.should include(a)
  #   report.validation_requests.should_not include(b)
  # end

  # # it "should be able to search within a range of dates" do
  # #   a = Bpm::LoanValidationEvent.create date: DateTime.new(2013, 4, 23, 13, 43)
  # #   b = Bpm::LoanValidationEvent.create date: DateTime.new(2013, 4, 25, 13, 43)
  # #   c = Bpm::LoanValidationEvent.create date: DateTime.new(2013, 4, 27, 13, 43)
  # #   report = build_report start_date: Date.new(2013, 4, 20), end_date: Date.new(2013, 4, 26)
  # #   report.validation_requests.should include(a)
  # #   report.validation_requests.should include(b)
  # #   report.validation_requests.should_not include(c)
  # # end

  # # it "should be able to search for requests after a single date" do
  # #   a = Bpm::LoanValidationEvent.create date: DateTime.new(2013, 4, 23, 13, 43)
  # #   b = Bpm::LoanValidationEvent.create date: DateTime.new(2013, 4, 25, 13, 43)
  # #   c = Bpm::LoanValidationEvent.create date: DateTime.new(2013, 4, 27, 13, 43)
  # #   report = build_report start_date: Date.new(2013, 4, 25)
  # #   report.validation_requests.should_not include(a)
  # #   report.validation_requests.should include(b)
  # #   report.validation_requests.should include(c)
  # # end

  # # it "should be able to search for requests prior to a single date" do
  # #   a = Bpm::LoanValidationEvent.create date: DateTime.new(2013, 4, 23, 13, 43)
  # #   b = Bpm::LoanValidationEvent.create date: DateTime.new(2013, 4, 25, 13, 43)
  # #   c = Bpm::LoanValidationEvent.create date: DateTime.new(2013, 4, 27, 13, 43)
  # #   report = build_report end_date: Date.new(2013, 4, 25)
  # #   report.validation_requests.should include(a)
  # #   report.validation_requests.should include(b)
  # #   report.validation_requests.should_not include(c)
  # # end

  # it "should sort results by underwriter" do
  #   a = Bpm::LoanValidationEvent.create underwriter: 'Fred Flintstone'
  #   b = Bpm::LoanValidationEvent.create underwriter: 'Barney Rubble'
  #   c = Bpm::LoanValidationEvent.create underwriter: 'Wilma Flintstone'
  #   report = build_report
  #   report.validation_requests.map{|x| x.loan_status.underwriter }.should == [ 'Barney Rubble', 'Fred Flintstone', 'Wilma Flintstone']
  # end

  # def build_report(opts={})
  #   BpmStatisticReport.new opts, without_protection: true
  # end

  # def make_error(message)
  #   Mdb::ValidationMessage.new type: 'error', message: message
  # end

  # def make_warning(message)
  #   Mdb::ValidationMessage.new type: 'warning', message: message
  # end
end
