require "spec_helper"

describe ClosingRequestsAwaitingReview do
  describe "instance methods" do
    smoke_test(:loan_id)
    smoke_test(:loan_purpose)
    smoke_test(:loan_status)
    smoke_test(:borrower)
    smoke_test(:state)
    smoke_test(:submitted_at)
    smoke_test(:closing_at)
    smoke_test(:lock_expire_at)

    context "sqlserver views" do
      it { ClosingRequestsAwaitingReview::CREATE_VIEW_SQL.should_not be_empty }
      it { ClosingRequestsAwaitingReview.should respond_to(:sqlserver_create_view) }
      it { ClosingRequestsAwaitingReview.sqlserver_create_view.should_not be_empty }
    end

    describe "#closing_request_notes" do
      it "should have note_type: CLREQ" do
        note = subject.closing_request_notes.new
        expect(note.note_type).to eq 'CLREQ' 
      end
      it '#latest_note_text' do
        note = subject.closing_request_notes.new(:text => 'testing')
        subject.stub_chain(:closing_request_notes, :first).and_return(note)
        subject.latest_note_text.should eq('testing')
      end
    end

    describe "#note_last_updated_by" do
      context "with no closing_request_notes" do
        its(:note_last_updated_by) { should be_nil }
      end

      context "with a closing note" do
        let(:updater) { 'Last Updater' }
        before do
          note = subject.closing_request_notes.new
          note.should_receive(:last_updated_by) { updater }
        end

        its(:note_last_updated_by) { should == updater }
      end
    end

    describe "#originator name" do
      context 'with no loan' do
        its(:originator_name) { should == nil }
      end

      context 'with a loan' do
        let!(:loan) { subject.build_loan }

        context 'with no originator' do
          its(:originator_name) { should == nil }
        end

        context 'with an originator' do
          before do
            loan.should_receive(:originator_name) { 'Originator Name' }
          end

          its(:originator_name) { should == 'Originator Name' }
        end
      end
    end
  end


  it '#branch_name' do
    subject.stub_chain(:loan, :branch_name).and_return('test')
    subject.branch_name.should eq('test')
  end


  context 'channel counts' do
    it 'submitted_at' do
      info = build_stubbed(:closing_requests_awaiting_review, :submitted_at => Date.yesterday, :channel => Channel.retail.abbreviation)
      ClosingRequestsAwaitingReview.stub_chain(:select, :order).and_return([info])
      counts = ClosingRequestsAwaitingReview.counts_by_channel_submitted
      yesterday = Date.yesterday.strftime('%m/%d/%Y')
      counts[yesterday][Channel.retail.abbreviation].should eql(1)
    end
    it 'closing_at' do
      info = build_stubbed(:closing_requests_awaiting_review, :closing_at => Date.yesterday, :channel => Channel.wholesale.abbreviation)
      ClosingRequestsAwaitingReview.stub_chain(:select, :order).and_return([info])
      counts = ClosingRequestsAwaitingReview.counts_by_channel_closed
      yesterday = Date.yesterday.strftime('%m/%d/%Y')
      counts[yesterday][Channel.wholesale.abbreviation].should eql(1)
    end
  end

end
