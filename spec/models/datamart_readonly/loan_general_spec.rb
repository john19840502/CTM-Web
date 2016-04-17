require "spec_helper"

describe LoanGeneral do
  subject { build_stubbed :loan_general }

  context "sqlserver views" do
    it { LoanGeneral::CREATE_VIEW_SQL.should_not be_empty }
    it { LoanGeneral.should respond_to(:sqlserver_create_view) }
    it { LoanGeneral.sqlserver_create_view.should_not be_empty }
  end

  describe '#purpose' do
    context 'when is_purchase? is true' do
      before { subject.stub(:is_purchase?) { true } }
      its(:purpose) { should == 'PURCHASE' }
    end

    context 'when is_refi? is true and is_purchase? and is_refi_plus? are false' do
      before do
        subject.stub(:is_refi?) { true }
        subject.stub(:is_purchase?) { false }
        subject.stub(:is_refi_plus?) { false }
      end

      its(:purpose) { should == 'REFINANCE' }
    end

    context 'when is_purchase? and is_refi? and is_refi_plus? are all false' do
      before do
        subject.stub(:is_refi?) { false }
        subject.stub(:is_refi_plus?) { false }
        subject.stub(:is_purchase?) { false }
      end

      its(:purpose) { should == '' }
    end


    context 'when product_code is blahblahRP' do
      before do
        subject.stub(:loan_purpose) { build_stubbed :loan_purpose, loan_type: '' }
        subject.stub(:product_code) { 'blahblahRP' }
      end
      its(:purpose) { should == 'REFIPLUS' }
    end

    context 'when loan_purpose is nil' do
      before do
        subject.stub(:loan_purpose) { nil }
      end
      its(:occupancy) { should == nil }
    end
  end

  describe '#product_code' do
    context 'when underwriting_datum product_code, chose that' do
      before do
        subject.stub(:underwriting_datum) { build_stubbed :underwriting_datum, product_code: 'FHA30' }
        subject.stub(:loan_feature) { build_stubbed :loan_feature, product_name: 'FHA20' }
        subject.stub(:lock_price) { build_stubbed :lock_price, product_code: 'FHA10' }
      end
      its(:product_code) { should == 'FHA30' }
    end

    context 'when underwriting_datum product_code not present, chose next' do
      before do
        subject.stub(:underwriting_datum) { build_stubbed :underwriting_datum, product_code: '' }
        subject.stub(:loan_feature) { build_stubbed :loan_feature, product_name: 'FHA20' }
        subject.stub(:lock_price) { build_stubbed :lock_price, product_code: 'FHA10' }
      end
      its(:product_code) { should == 'FHA20' }
    end

    context 'when nothing else, chose lock_price' do
      before do
        subject.stub(:underwriting_datum) { build_stubbed :underwriting_datum, product_code: '' }
        subject.stub(:loan_feature) { build_stubbed :loan_feature, product_name: '' }
        subject.stub(:lock_price) { build_stubbed :lock_price, product_code: 'FHA10' }
      end
      its(:product_code) { should == 'FHA10' }
    end

  end

  describe '#originator_name' do
    context 'when the loan has an originator' do
      before do
        originator = build_stubbed :datamart_user
        originator.should_receive(:name) { "Originator Name" }
        subject.stub(:originator) { originator }
      end

      its(:originator_name) { should == "Originator Name" }
    end

    context 'when the loan has no originator' do
      before do
        subject.stub(:originator) { nil }
      end

      it 'should use lo_first_name and lo_last_name' do
        subject.stub(:lo_first_name) { 'First' }
        subject.stub(:lo_last_name) { 'Last' }
        expect(subject.originator_name).to eq 'First Last'
      end
    end
  end

  describe ".application_date" do

    it "should return date of single compliance alert" do
      date = 3.days.ago
      alert = build_stubbed(:compliance_alert, application_date: date)
      subject.stub(:compliance_alerts) {[alert]}

      expect(subject.application_date).to eq date
    end

    it "should return the most recent date if there are multiple alerts" do
      date = 5.minutes.ago
      alerts = []
      [3,2,1].each do |num|
        alerts << build_stubbed(:compliance_alert, application_date: num.days.ago)
      end
      alerts << build_stubbed(:compliance_alert, application_date: date)
      subject.stub(:compliance_alerts) {alerts}

      expect(subject.application_date).to eq date
    end

    it "should return nil if there are no alerts" do
      subject.stub(:compliance_alerts) {[]}
      expect(subject.application_date).to be_nil
    end

  end

  describe '#secondary financing calculations' do
    before do
      liabilities = []
      (1..3).each do |i|
        liabilities << build_stubbed(:liability, unpaid_balance_amount: 500 * i, subject_loan_resubordination_indicator: i % 2 == 1 ? true : false)
      end

      subject.stub(:liabilities) { liabilities }

      transaction_detail = build_stubbed :transaction_detail, subordinate_lien_amount: 500, undrawn_heloc_amount: 100
      subject.stub(:transaction_detail) { transaction_detail }
    end

    context 'only when liability subject_loan_resubordination_indicator is == "Y"' do

      it 'should include amounts in total_balance_secondary_financing' do
        expect(subject.total_balance_secondary_financing).to eq 2500
      end

      it 'should include amounts in max_amount_secondary_financing' do
        expect(subject.max_amount_secondary_financing).to eq 2600
      end
    end
  end

  describe ".disclosed?" do

    it "requires loan events" do
      subject.stub(:loan_events).and_return([])

      expect(subject.disclosed?).to be_falsey
    end

    it "looks for event description" do
      events = []
      events << event('Loan Lock Submitted')
      events << event('DocMagic Initial Disclosure Request')
      events << event('Loan Lock Submitted')
      subject.stub(:loan_events).and_return(events)

      expect(subject.disclosed?).to be_truthy
    end

    it "requires initial disclosure event" do
      events = []
      events << event('Loan Lock Submitted')
      events << event('Loan Lock Submitted')
      subject.stub(:loan_events).and_return(events)

      expect(subject.disclosed?).to be_falsey
    end

    def event description
      event = double
      allow(event).to receive(:event_description).and_return(description)
      event
    end

  end

  describe ".intent_to_proceed_date" do

    it "converts the data into a datetime" do
      subject.stub_chain(:custom_fields, :intent_to_proceed_date_string).and_return("10/15/2015")

      expect(subject.intent_to_proceed_date).to eq DateTime.new(2015, 10, 15)
    end

    it "handles a nil date" do
      subject.stub_chain(:custom_fields, :intent_to_proceed_date_string).and_return(nil)

      expect(subject.intent_to_proceed_date).to be_nil
    end

  end

end
