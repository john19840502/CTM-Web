require "spec_helper"

describe ScheduledFunding do
  smoke_test :id
  smoke_test :borrower_last_name
  smoke_test :loan_purpose
  smoke_test :channel
  smoke_test :borrower_requested_loan_amount
  smoke_test :disbursed_at

  context "sqlserver views" do
    it { ScheduledFunding::CREATE_VIEW_SQL.should_not be_empty }
    it { ScheduledFunding.should respond_to(:sqlserver_create_view) }
    it { ScheduledFunding.sqlserver_create_view.should_not be_empty }
  end

  describe 'class methods' do
    subject { ScheduledFunding }

    it '.channel_options' do
      subject.channel_options.should be_instance_of(Array)
      subject.channel_options.should eq(Channel.all.map(&:identifier))
    end

    describe '#filter_by_date' do
      it 'should only give loans with disbursements between the given dates' do
        date = subject.maximum(:disbursed_at)
        expect(subject.where(:disbursed_at => date).count).to eq subject.filter_by_date(date, date).count
      end
    end
  end

  describe '#property_state' do
    context 'with no property' do
      its(:property_state) { should be_nil }
    end

    context 'with a property' do
      before do
        subject.property = Property.new({state: "Property State"}, without_protection: true)
      end

      its(:property_state) { should == "Property State"}
    end
  end

  describe '#branch_listing' do
    context 'with no branch' do
      its(:branch_listing) { should == ' - ' }
    end

    context 'with a branch' do
      before do
        subject.stub(:branch) { Institution.new({id: 12345, name: "Branch Name", institution_number: 999}, without_protection: true) }
      end

      its(:branch_listing) { should == "999 - Branch Name" }
    end
  end

  describe '#note_last_updated_by' do
    context 'it does not have a ctm_user' do
      its(:note_last_updated_by) { should be_nil }
    end

    context 'it has a ctm_user' do
      before do
        ctm_user = build_stubbed :ctm_user, domain_login: "User Name"
        subject.ctm_user = ctm_user
      end
      its(:note_last_updated_by) { should == "User Name" }
    end
  end

  it "should find by id" do
    funding = ScheduledFunding.first
    id = funding.id
    ScheduledFunding.find(id.to_i).should == funding
  end
end
