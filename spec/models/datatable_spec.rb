require "spec_helper"

describe Datatable do


  let(:datatable) { Datatable.new }

  before(:each) do 
    datatable.label = "Closing Requests Awaiting Review"
    datatable.model = ClosingRequestsAwaitingReview #= FactoryGirl.build_stubbed(:closing_requests_awaiting_review)
    datatable.columns = [:loan_id, :submitted_at]
  end

  it "should instantiate" do
    datatable.class.name.should eql("Datatable")
  end

  it "should return all records by default" do 
    datatable.model.should_receive(:all).and_return([])
    datatable.record_list
  end

  it "should not return anything because of custom records" do 
    datatable.model.should_not_receive(:all)
    datatable.records = []
    datatable.record_list
  end

  describe "to_xls" do
    it "should generate an xls" do
      datatable.records =  [FactoryGirl.build_stubbed(:closing_requests_awaiting_review)]
      datatable.to_xls.should_not be_nil
      datatable.to_xls.should be_instance_of(String)
    end
  end


  

end
