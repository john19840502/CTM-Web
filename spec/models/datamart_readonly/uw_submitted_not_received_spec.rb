require "spec_helper"

describe UwSubmittedNotReceived do

  context "sqlserver views" do
    it { UwSubmittedNotReceived::CREATE_VIEW_SQL.should_not be_empty }
    it { UwSubmittedNotReceived.should respond_to(:sqlserver_create_view) }
    it { UwSubmittedNotReceived.sqlserver_create_view.should_not be_empty }
  end

  describe "instance methods" do
    smoke_test :loan_id
    smoke_test :uw_submitted_at
    smoke_test :age
    smoke_test :coordinator_pid
    smoke_test :channel
    smoke_test :purpose
    smoke_test :borrower_last_name
    smoke_test :is_mi_required
    smoke_test :mortgage_type
    smoke_test :product_code
    smoke_test :is_jumbo_candidate

    it '#date_counts' do
      data = FactoryGirl.build_stubbed(:uw_submitted_not_received, :uw_submitted_at => Time.now.utc)
      UwSubmittedNotReceived.stub_chain(:select, :order, :all).and_return([data])
      UwSubmittedNotReceived.date_counts.should_not be_nil
    end

    it '#missing_uw_submission_date_count' do
      UwSubmittedNotReceived.should_receive(:where).with(:uw_submitted_at => nil).and_return([])
      UwSubmittedNotReceived.missing_uw_submission_date_count.should eq(0)
    end
  end
end
