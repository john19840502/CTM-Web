require "spec_helper"

describe LoanNote do
  smoke_test :id
  smoke_test :loan_id
  smoke_test :text
  smoke_test :note_type
  smoke_test :scheduled_funding

  context "sqlserver views" do
    it { LoanNote::CREATE_VIEW_SQL.should_not be_empty }
    it { LoanNote.should respond_to(:sqlserver_create_view) }
    it { LoanNote.sqlserver_create_view.should_not be_empty }
  end

  describe '#last_updated_by' do
    context 'note does not have a ctm_user' do
      its(:last_updated_by) { should be_nil }
    end

    it '#note_type' do
      data = FactoryGirl.build_stubbed(:loan_note)
      data.valid?
      data.errors[:note_type].size.should == 1
    end

    it '#text' do
      data = FactoryGirl.build_stubbed(:loan_note)
      data.valid?
      data.errors[:text].size.should == 1
    end

    it '#to_label' do
      data = FactoryGirl.build_stubbed(:loan_note, text: 'Testing')
      data.to_label.should eq('Testing')
    end

    context 'note have a ctm_user' do
      before do
        ctm_user = build_stubbed :ctm_user, domain_login: "User Name"
        subject.ctm_user = ctm_user
      end
      its(:last_updated_by) { should == "User Name" }
    end
  end
end
