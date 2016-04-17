require 'spec_helper'

describe Smds::UlddBorrower do

  shared_examples_for "a borrower enumeration" do |method, source, legal_values|
    legal_values.each do |value|
      it "should be #{value} when #{source} is #{value}" do
        loan.stub source => value
        subject.public_send(method).should == value
      end
    end

    it "should be blank for other values" do
      loan.stub source => 'NA'
      subject.public_send(method).should == ''
    end
  end

  let(:loan) { Smds::FhlmcLoan.new }
  let(:index) { 2 }
  let(:borrower) { Master::Person::Borrower.new }
  let(:compass_loan) { Smds::CompassLoanDetail.new }
  subject { Smds::UlddBorrower.new loan, index }

  before do
    subject.stub(:master_borrower) { borrower }
    subject.stub(:compass_loan_detail) { compass_loan }
  end

  it "should get stuff from the version of the field specified by the index" do
    loan.stub Brw1CreditScoreSource: 'Experian'
    loan.stub Brw2CreditScoreSource: 'Equifax'

    Smds::UlddBorrower.new(loan, 1).credit_score_source.should == 'Experian'
    Smds::UlddBorrower.new(loan, 2).credit_score_source.should == 'Equifax'
  end

  it "should get last name" do
    borrower.stub last_name: 'Bob'
    subject.last_name.should == 'Bob'
  end

  it "should restrict middle name to a single letter" do
    borrower.stub middle_name: 'Fred'
    subject.middle_name.should == 'F'
  end

  it "should get suffix" do
    borrower.stub suffix: 'Fred'
    subject.suffix.should == 'Fred'
  end

  describe "borrower_age_at_application" do
    before { loan.stub ApplicationReceivedDate: Date.new(2016,2,28) }

    it "should return 31 if birthday is on same day" do
      borrower.birth_date = Date.new(1985,2,28)
      expect(subject.borrower_age_at_application ).to eq 31
    end

    it "returns 30 when the birthday is greater than application date" do
      borrower.birth_date = Date.new(1985,3,29)
      expect(subject.borrower_age_at_application ).to eq 30
    end
  end

  describe "address_type" do
    it "should be mailing when there is a different property address" do
      loan.stub DifferentPropertyAddress: 'Y'
      subject.address_type.should == 'Mailing'
    end

    it "should be blank if there is not a different property address" do
      loan.stub DifferentPropertyAddress: 'N'
      subject.address_type.should == ''
    end
  end

  describe "country code" do
    it "should be blank if the property address is the mailng address" do
      loan.stub DifferentPropertyAddress: 'N'
      loan.stub USAddress: 'Y'
      subject.country_code.should == ''
    end

    it "should be blank if the mailing address is outside the us" do
      loan.stub DifferentPropertyAddress: 'Y'
      loan.stub USAddress: 'N'
      subject.country_code.should == ''
    end

    it "should be 'US' otherwise" do
      loan.stub DifferentPropertyAddress: 'Y'
      loan.stub USAddress: 'Y'
      subject.country_code.should == 'US'
    end
  end

  [ [ :address, :MailingStreetAddress, 100 ],
    [ :cityname, :MailingCity, 50 ],
    [ :postal_code, :MailingPostalCode, 9 ],
    [ :state_code, :MailingState, 2 ],
  ].each do |method, source, max_length|
    describe "##{method}" do
      let(:result) { subject.public_send(method) }
      it "should be empty when #{source} is null or NA" do
        loan.stub DifferentPropertyAddress: 'Y'
        [nil, 'NA'].each do |value|
          loan.stub source => value
          result.should == ''
        end
      end

      it "should be empty when property address is same as borrower address" do
        loan.stub DifferentPropertyAddress: 'N'
        loan.stub source => "asldfjdsf"
        result.should == ''
      end

      it "should take the first #{max_length} chars of the #{source}" do
        loan.stub DifferentPropertyAddress: 'Y'
        loan.stub source => 'a'*max_length + '123'
        result.should == 'a'*max_length
      end
    end
  end

  describe "#birth_date" do
    before { borrower.stub birth_date: Date.new(1955, 1, 1) }
    let(:result) { subject.birth_date }

    it "should use blank instead of 1/1/1900" do
      borrower.stub birth_date: Date.new(1900, 1, 1)
      result.should == ''
    end

    it "should format the date properly otherwise" do
      borrower.stub birth_date: Date.new(1999, 1, 15)
      result.should == '1999-01-15'
    end
  end

  describe "#classification_type" do
    it "should be 'Primary' for the first borrower" do
      Smds::UlddBorrower.new(loan, 1).classification_type.should == 'Primary'
    end

    it "should be 'Secondary' for all others" do
      [2, 3, 4].each do |index|
        Smds::UlddBorrower.new(loan, index).classification_type.should == 'Secondary'
      end
    end
  end

  describe "#address_same_as_property?" do
    it "should be true when DifferentPropertyAddress is false" do
      ['N', 'NA', nil, ''].each do |value|
        loan.stub DifferentPropertyAddress: value
        subject.address_same_as_property?.should == true
      end
    end

    it "should be false when DifferentPropertyAddress is true" do
      loan.stub DifferentPropertyAddress: 'Y'
      subject.address_same_as_property?.should == false
    end
  end

  describe "#qualifying_income" do
    let(:result) { subject.qualifying_income }
    it "should show zeroes" do
      borrower.stub qualifying_income: 0
      result.should == '0'
    end

    it "should replace NA with 0" do
      borrower.stub qualifying_income: 'NA'
      result.should == '0'
    end

    it "should be an integer and use the value of master borrower qualifying income" do
      borrower.stub qualifying_income: 12345.789
      result.should == '12345'
    end
  end

  describe "credit_score_source" do
    let(:result) { subject.credit_score_source }
    let(:indicator) { subject.credit_score_indicator }

    ['Experian', 'TransUnion', 'Equifax'].each do |agency_name|
      it "should be #{agency_name} when the source contains that" do
        loan.stub Brw2CreditScoreSource: 'sdlkfj' + agency_name.downcase + 'dlfjasdf'
        result.should == agency_name
        indicator.should == true
      end
    end

    it "should be empty otherwise" do
      ['NA', 'dslfjsflkj', nil].each do |value|
        loan.stub Brw2CreditScoreSource: value
        result.should == ''
        indicator.should == false
      end
    end

    it "should be blank for borrowers 3 and 4 because they don't have this info in compass loan details" do
      loan.stub(:Brw3CreditScoreSource).and_raise("There is no such field")
      loan.stub(:Brw4CreditScoreSource).and_raise("There is no such field")
      Smds::UlddBorrower.new(loan, 3).credit_score_source.should == ''
      Smds::UlddBorrower.new(loan, 4).credit_score_source.should == ''
    end

  end

  describe "credit_score" do
    before do
      borrower.stub credit_score: 123
      loan.stub Brw2CreditScoreSource: 'Experian'
    end
    let(:result) { subject.credit_score }

    it "should be the basic score from the borrower if there is no middle credit score" do
      result.should == '123'
    end

    it 'should be the middle credit score if there is one' do
      borrower.stub(:middle_credit_score) { 500 }
      result.should == '500'
    end
  end


  describe "bankruptcy indicator" do
    it "should be true if loan.Bankruptcy is Y and this is the primary borrower" do
      loan.stub Bankruptcy: 'Y'
      Smds::UlddBorrower.new(loan, 1).bankruptcy_indicator.should == true
    end

    it "should be false if this is not the primary borrower" do
      loan.stub Bankruptcy: 'Y'
      Smds::UlddBorrower.new(loan, 2).bankruptcy_indicator.should == false
    end

    it "should be false when Bankruptcy is not 'Y'" do
      ['', 'NA', 'N', nil].each do |value|
        loan.stub Bankruptcy: value
        subject.bankruptcy_indicator.should == false
      end
    end
  end

  describe "first time homebuyer indicator" do
    let(:result) { subject.first_time_homebuyer_indicator }

    before do
      loan.stub LoanPurposeType: 'Purchase'
      loan.stub PropertyUsageType: 'PrimaryResidence'
    end

    it "should be blank if the loan is not for purchase" do
      loan.stub LoanPurposeType: 'Refinance'
      result.should == ''
    end

    it "should be blank if the property is not a primary residence" do
      loan.stub PropertyUsageType: 'slfkj'
      result.should == ''
    end

    it "should be true if FirstTimeHomebuyer is 'Y'" do
      loan.stub FirstTimeHomebuyer: 'Y'
      result.should == true
    end

    it "should be false otherwise" do
      ['N', 'NA', '', nil].each do |value|
        loan.stub FirstTimeHomebuyer: value
        result.should == false
      end
    end
  end

  describe "citizenship residency type" do
    context 'with valid value' do
      before { borrower.stub citizenship_type: 'USCitizen' }
      its(:citizenship_type) { should == 'USCitizen' }
    end

    context 'with invalid value' do
      before { borrower.stub citizenship_type_type: 'Martian' }
      its(:citizenship_type) { should == '' }
    end
  end

  describe "foreclosure_indicator" do
    let(:lg) { FactoryGirl.build_stubbed(:loan_general)}
    let(:declaration)   { double("Declaration")}
    let(:declarations)  { [build_stubbed(:declaration, borrower_id: 'BRW1', loan_foreclosure_or_judgement_indicator: true), 
                        build_stubbed(:declaration, borrower_id: 'BRW2', loan_foreclosure_or_judgement_indicator: false)]}
    let(:result) { subject.foreclosure_indicator }

    before do
      loan.stub loan_general: lg
      loan.loan_general.stub declarations: declarations
    end

    context "for the primary borrower" do
      subject { Smds::UlddBorrower.new loan, 1 }

      it "should be true when Foreclosure is 'Y'" do
        allow(loan.loan_general).to receive(:loan_forceclosure_indicator).with(1).and_return(loan.loan_general.declarations.first.loan_foreclosure_or_judgement_indicator)
        result.should == true
      end
    end

    context "for secondary borrowers" do
      subject { Smds::UlddBorrower.new loan, 2 }
      it "should be included no matter the value of Foreclosure" do
        allow(loan.loan_general).to receive(:loan_forceclosure_indicator).with(2).and_return(loan.loan_general.declarations.last.loan_foreclosure_or_judgement_indicator)
        result.should == false
      end
    end
  end

  describe "self_employment_indicator" do
    let(:result) { subject.self_employment_indicator }

    context "for the primary borrower" do
      subject { Smds::UlddBorrower.new loan, 1 }

      it "should be true when SelfEmpFlg is 'Y'" do
        loan.stub SelfEmpFlg: 'Y'
        result.should == true
      end

      it "should be false when SelfEmpFlg is anything else" do
        ['N', 'NA', '', nil].each do |value|
          loan.stub SelfEmpFlg: value
          result.should == false
        end
      end
    end

    context "for secondary borrowers" do
      subject { Smds::UlddBorrower.new loan, 2 }

      it "should not be blank no matter the value of SelfEmpFlg" do
        ['Y', 'N'].each do |value|
          loan.stub SelfEmpFlg: value
          result.should_not be_blank
        end
      end
    end
  end

  describe "gender" do
    context 'with valid value' do
      before { allow(compass_loan).to receive(:gender_type).with(1).and_return("Male") }
      it "should return the gender if gender type is valid" do
        expect(subject.gender(1)).to eq "Male"
      end
    end

    context 'with invalid value' do
      before { allow(compass_loan).to receive(:gender_type).with(2).and_return('Martian') }
      it "should return '' when the gender_type is not valid" do
        expect(subject.gender(2)).to eq ''
      end
    end
  end

  describe "ethnicity" do
    context 'with valid value' do
      before { borrower.stub hmda_ethnicity_type: 'HispanicOrLatino' }
      its(:ethnicity) { should == 'HispanicOrLatino' }
    end

    context 'with invalid value' do
      before { borrower.stub hmda_ethnicity_type: 'Martian' }
      its(:ethnicity) { should == '' }
    end
  end

  describe "taxpayer_identifier" do
    it "should be only 9 digits" do
      borrower.stub ssn: '1234567890'
      subject.taxpayer_identifier.should == '123456789'
    end

    it "should be blank when the source is NA" do
      borrower.stub ssn: 'NA'
      subject.taxpayer_identifier.should == ''
    end
  end

  describe "credit_report_identifier" do
    it "should be the last one with the right engine code and status" do
      borrower.stub credit_reports: [
        make_cr(credit_report_identifier: 1, engine_code: "foo", order_status: "Success"),
        make_cr(credit_report_identifier: 2, engine_code: "fannie", order_status: "Fail"),
        make_cr(credit_report_identifier: 3, engine_code: "fannie", order_status: "Success"),
        make_cr(credit_report_identifier: 4, engine_code: "fannie", order_status: "Success"),
      ]

      expect(subject.credit_report_identifier).to eq 4
    end

    def make_cr(options={})
      Master::CreditReport.new(options, without_protection: true)
    end
  end

end
