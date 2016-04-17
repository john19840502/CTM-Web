require "spec_helper"

describe ClosingRequestReadyForDoc do
  describe "instance methods" do
    smoke_test(:loan_id)
    smoke_test(:purpose)
    smoke_test(:borrower_last_name)
    smoke_test(:branch_name)
    smoke_test(:state)
    smoke_test(:requester_submitted_at)
    smoke_test(:closed_at)
    smoke_test(:assigned_to)
    smoke_test(:requester_submitted_date)
    smoke_test(:closing_date)


    context "sqlserver views" do
      it { ClosingRequestReadyForDoc::CREATE_VIEW_SQL.should_not be_empty }
      it { ClosingRequestReadyForDoc.should respond_to(:sqlserver_create_view) }
      it { ClosingRequestReadyForDoc.sqlserver_create_view.should_not be_empty }
    end
  end


  context 'count functions' do
    it 'count_by_date' do
      ClosingRequestReadyForDoc.stub_chain(:group, :count).and_return({"01/25/12"=>3, "01/26/12"=>16, "01/27/12"=>21})
      ClosingRequestReadyForDoc.should_receive(:group)
      ClosingRequestReadyForDoc.count_by_date.count.should eql(3)
    end
    it 'counts by channel' do
      info = build_stubbed(:closing_request_ready_for_doc, closed_at: Date.yesterday, :channel => Channel.retail.abbreviation)
      ClosingRequestReadyForDoc.stub_chain(:select, :order).and_return([info])
      result = ClosingRequestReadyForDoc.counts_by_channel
      result.length.should eql(1)
      yesterday = Date.yesterday.strftime('%m/%d/%Y')
      result[yesterday][Channel.retail.abbreviation].should eql(1)
    end
  end
end
