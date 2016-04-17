require 'spec_helper'
require 'bpm/report_csv_dumper'

describe Bpm::ReportCsvDumper do
  let(:requests) { [] }
  let(:qr) { BpmStatisticReport.new }
  let(:result) { subject.dump qr }
  let(:lines) { result.lines.map(&:chomp) }
  before do
    qr.stub validation_requests: requests 
  end

  it "should have the column names in the first row" do
    expected_names = ["validated_by", "validated_by_id", "date", 
      "total_rules_applied", "validation_type", "loan_num", "underwriter", 
      "product_code", "channel", "state", "status", "pipeline_status", "type", "message",
    ].join(',')
    result.lines.first.chomp.should == expected_names
  end

  it "should export validated_by in the first column" do
    requests << Mdb::ValidationRequest.new(validated_by: 'Fred Flintstone')
    requests << Mdb::ValidationRequest.new(validated_by: 'Barney Rubble')
    field_values(0).should == [ 'Fred Flintstone', 'Barney Rubble' ]
  end

  it "should export validated_by_id in the second column" do
    requests << Mdb::ValidationRequest.new(validated_by_id: 123)
    requests << Mdb::ValidationRequest.new(validated_by_id: 456)
    field_values(1).should == [ '123', '456' ]
  end

  it "should export date in the third column" do
    requests << Mdb::ValidationRequest.new(date: DateTime.new(2013, 2, 3, 12, 34))
    requests << Mdb::ValidationRequest.new(date: DateTime.new(2013, 2, 5, 13, 34))
    field_values(2).should == [ '2013-02-03 12:34:00', '2013-02-05 13:34:00' ]
  end

  it "should export the number of rules applied in the fourth column" do
    requests << Mdb::ValidationRequest.new(total_rules_applied: 123)
    requests << Mdb::ValidationRequest.new(total_rules_applied: 345)
    field_values(3).should == [ '123', '345']
  end

  it "should export the validation type in the fifth column" do
    requests << Mdb::ValidationRequest.new(validation_type: 'uw_validation')
    requests << Mdb::ValidationRequest.new(validation_type: 'reg val')
    field_values(4).should == [ 'uw_validation', 'reg val' ]
  end

  it "loan num" do
    requests << Mdb::ValidationRequest.new(loan_status_attributes: { loan_num: '1234567'})
    requests << Mdb::ValidationRequest.new(loan_status_attributes: { loan_num: '1666777'})
    field_values(5).should == [ '1234567', '1666777' ]
  end

  it "underwriter" do
    requests << Mdb::ValidationRequest.new(loan_status_attributes: { underwriter: 'bob'})
    requests << Mdb::ValidationRequest.new(loan_status_attributes: { underwriter: 'fred'})
    field_values(6).should == [ 'bob', 'fred' ]
  end

  it "product_code" do
    requests << Mdb::ValidationRequest.new(loan_status_attributes: { product_code: 'ABC'})
    requests << Mdb::ValidationRequest.new(loan_status_attributes: { product_code: 'C39'})
    field_values(7).should == [ 'ABC', 'C39' ]
  end

  it "channel" do
    requests << Mdb::ValidationRequest.new(loan_status_attributes: { channel: 'A0'})
    requests << Mdb::ValidationRequest.new(loan_status_attributes: { channel: 'C0'})
    field_values(8).should == [ 'A0', 'C0' ]
  end

  it "state" do
    requests << Mdb::ValidationRequest.new(loan_status_attributes: { state: 'MI'})
    requests << Mdb::ValidationRequest.new(loan_status_attributes: { state: 'OH'})
    field_values(9).should == [ 'MI', 'OH' ]
  end

  it "status" do
    requests << Mdb::ValidationRequest.new(loan_status_attributes: { status: 'Sold'})
    requests << Mdb::ValidationRequest.new(loan_status_attributes: { status: 'Lock Expired'})
    field_values(10).should == [ 'Sold', 'Lock Expired' ]
  end

  it "pipeline_status" do
    requests << Mdb::ValidationRequest.new(loan_status_attributes: { pipeline_status: 'foo'})
    requests << Mdb::ValidationRequest.new(loan_status_attributes: { pipeline_status: 'bar'})
    field_values(11).should == [ 'foo', 'bar' ]
  end

  describe "type field" do
    let(:values) { field_values(12) }

    context "when there are no errors" do
      before do
        requests << Mdb::ValidationRequest.new(validation_messages: [])
      end

      it { values.should == ['No errors or warnings']}
    end

    context "when there is only one error" do
      before do
        requests << Mdb::ValidationRequest.new(validation_messages: [
          Mdb::ValidationMessage.new(type: 'error', message: 'foo'),
        ])
      end

      it { values.should == ['error']}
    end

    context "when there is only one warning" do
      before do
        requests << Mdb::ValidationRequest.new(validation_messages: [
          Mdb::ValidationMessage.new(type: 'warning', message: 'foo'),
        ])
      end

      it { values.should == ['warning']}
    end

    context "when a request has multiple messages" do
      before do
        requests << Mdb::ValidationRequest.new(validated_by: 'fred',
          validation_messages: [
            Mdb::ValidationMessage.new(type: 'warning', message: 'foo'),
            Mdb::ValidationMessage.new(type: 'error', message: 'bar'),
        ])
      end

      it "should unroll the messages" do
        values.should == [ 'warning', 'error' ]
      end
      
      it "should repeat the request's other values" do
        field_values(0).should == [ 'fred', 'fred' ]
      end

      it "should put the messages in there too" do
        field_values(13).should == [ 'foo', 'bar' ]
      end
    end
  end



  def field_values(index)
    lines.drop(1).map {|line| line.split(',') }.map {|v| v[index] }
  end
end
