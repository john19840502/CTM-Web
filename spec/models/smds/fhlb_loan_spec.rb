require 'spec_helper'

describe Smds::FhlbLoan do
  it { should be_a Smds::FhlbLoan }

  it "should returh FHLB as delivery type" do
    expect(subject.delivery_type).to eq "FHLB"
  end

  describe "InvestorRemittanceDay" do
    it "should be always 18 for Fhlb" do
      expect(subject.InvestorRemittanceDay).to eq '18'
    end
  end

  describe "InvestorRemittanceType" do
    it "should be always ActualInterestActualPrincipal" do
      expect(subject.InvestorRemittanceType).to eq 'ActualInterestActualPrincipal'
    end
  end

  describe "InvestorCommitmentIdentifier" do
    let(:compass_loan_detail) { Smds::CompassLoanDetail.new }
    it "should return InvestorCommitNbr from Compass loan detail" do
      subject.stub compass_loan_detail: compass_loan_detail
      compass_loan_detail.stub_chain(investor_commitment_number: "FH654328")
      expect(subject.InvestorCommitmentIdentifier).to eq "654328"
    end
  end

  describe "LoanAcquisitionScheduledUPBAmount" do
    it "should return '' when CalcSoldScheduledBal is nil " do
      expect(subject.LoanAcquisitionScheduledUPBAmount).to eq '' 
    end
    it "should return value stored in CalcSoldScheduledBal by rounding it to 2 decimal points" do
      subject.stub CalcSoldScheduledBal: 23.456
      expect(subject.LoanAcquisitionScheduledUPBAmount).to eq 23.46
    end
  end
end