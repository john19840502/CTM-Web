require 'spec_helper'

describe LoanComplianceFilter do
  before do
    # LoanComplianceEvent.delete_all
  end

  describe "#filter_query" do
    let!(:import1) { LoanComplianceEvent.create(aplnno: 1234,propstreet: "TBD", propcity: "TBD", propstate: "TBD", propzip: "TBD", preappr: 3, actdate: Date.new(2012, 11, 1)) }
    let!(:import2) { LoanComplianceEvent.create(aplnno: 1234,propstreet: "TBD", propcity: "TBD", propstate: "TBD", propzip: "TBD", preappr: 2, actdate: Date.new(2012, 11, 1)) }
    let!(:import3) { LoanComplianceEvent.create(aplnno: 1234,propstreet: "123 Main St.", propcity: "Main", propstate: "Main", propzip: "12345", preappr: 1, actdate: Date.new(2012, 11, 1)) }
    let!(:type) { 'q' }
    let!(:period) { "actdate >= '2012-11-01' and actdate < '2012-11-30'" }
    it "should return all loan events" do
      filter = LoanComplianceFilter.new()
      filter.filter_query(period, type).should == []
    end

    it "should return all loan events where preappr is 2 or 3 with addresses TBD and preappr 1 where addresses are not TBD" do
      filter = LoanComplianceFilter.find("1")
      filter.filter_query(period, type).should == [import1, import2]
    end
  end

  describe "#filter_columns" do
    let!(:nil_columns) { [] }
    it "should not return any columns" do
      filter = LoanComplianceFilter.new()
      filter.filter_columns.should == nil_columns
    end

    it "should return preapproval columns" do
      filter = LoanComplianceFilter.find("1")
      filter.filter_columns.should == ["action_code", "preappr", "propstreet", "propcity", "propstate", "propzip", "last_updated_by"]
    end
  end

  describe "#filter_title" do
    let!(:default) { 'HMDA Filters' }
    it "should not return any columns" do
      filter = LoanComplianceFilter.new()
      filter.filter_title.should == default
    end

    it "should return preapproval columns" do
      filter = LoanComplianceFilter.find("1")
      filter.filter_title.should == 'HMDA Preapprovals Filter'
    end
  end

end
