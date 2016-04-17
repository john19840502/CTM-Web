
require 'spec_helper'

describe Master::Person::Borrower do

  describe "is_us_citizen?" do
    it "should be true when citizenship_type is USCitizen" do
      subject.citizenship_type = "USCitizen"
      subject.is_us_citizen?.should be true
    end
    [ "NonPermanentResidentAlien", "PermanentResidentAlien", ].each do |v|
      it "should be true when citizenship_type is #{v}" do
        subject.citizenship_type = v
        subject.is_us_citizen?.should be false
      end
    end
  end

  describe "is_permanent_resident?" do
    [ "USCitizen", "PermanentResidentAlien", ].each do |v|
      it "should be true when citizenship_type is #{v}" do
        subject.citizenship_type = v
        subject.is_permanent_resident?.should be true
      end
    end
    it "should be false when citizenship_type is NonPermanentResidentAlien" do
      subject.citizenship_type = "NonPermanentResidentAlien"
      subject.is_permanent_resident?.should be false
    end
  end

  describe "employer" do
    let(:loan) { Master::Loan.find(751) }
    subject { loan.primary_borrower }
    it "should be the first employer for this borrower" do
      subject.employer.name.should == "Sentinel Technologies"
    end
  end

  describe "residence" do
    let(:loan) { Master::Loan.find(751) }
    subject { loan.primary_borrower }
    it "should be the first residence for this borrower" do
      subject.residence.borrower_id.should == 'BRW1'
    end
  end

  describe "credit_reports" do
    let(:loan) { Master::Loan.find(751) }
    subject { loan.primary_borrower }

    it "brw1 should include all reports from the loan which match position" do
      subject.stub borrower_id: "BRW1"
      loan.stub credit_reports: [
        make_cr(id: 1, borrower_position: "1"),
        make_cr(id: 2, borrower_position: "12"),
        make_cr(id: 3, borrower_position: "34"),
      ]
      expect(subject.credit_reports.map(&:id)).to eq [1,2]
    end

    it "brw3 should include all reports from the loan which match position" do
      subject.stub borrower_id: "BRW3"
      loan.stub credit_reports: [
        make_cr(id: 1, borrower_position: "3"),
        make_cr(id: 2, borrower_position: "12"),
        make_cr(id: 3, borrower_position: "34"),
      ]
      expect(subject.credit_reports.map(&:id)).to eq [1,3]
    end

    def make_cr(options={})
      Master::CreditReport.new(options, without_protection: true)
    end
  end

end
