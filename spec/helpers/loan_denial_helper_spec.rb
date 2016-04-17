require 'spec_helper'

describe LoanDenialHelper do
  let(:loan) {Master::Loan.new}

  describe ".denial_cancel_or_withdrawal_date" do

    it "should return denial date if it is set" do
      date = 1.day.ago
      loan.denied_at = date
      loan.cancelled_or_withdrawn_at = nil

      expect(helper.denial_cancel_or_withdrawal_date(loan)).to eq date
    end

    it "should return cancel or withdrawal date if it is set" do
      date = 5.hours.ago
      loan.denied_at = nil
      loan.cancelled_or_withdrawn_at = date

      expect(helper.denial_cancel_or_withdrawal_date(loan)).to eq date
    end

    it "should return nil if neither date exists" do
      loan.denied_at = nil
      loan.cancelled_or_withdrawn_at = nil

      expect(helper.denial_cancel_or_withdrawal_date(loan)).to be_nil
    end

    it "should select denial date if both dates are set" do
      date = 5.hours.ago
      loan.denied_at = date
      loan.cancelled_or_withdrawn_at = 2.days.ago

      expect(helper.denial_cancel_or_withdrawal_date(loan)).to eq date
    end

  end

  describe ".borrower_email" do

    it "should return the borrower's email" do
      borrower = double
      email = "foo@bar.com"
      allow(borrower).to receive(:email).and_return(email)
      loan.stub(:primary_borrower).and_return(borrower)

      expect(helper.borrower_email(loan)).to eq email
    end

    it "should return nil if no borrower found" do
      loan.stub(:primary_borrower).and_return(nil)
      expect(helper.borrower_email(loan)).to be_nil
    end

  end

  describe ".custom_loan_data" do

    it "should return an existing custom data for a loan" do
      data = Master::LoanDetails::CustomLoanData.new
      loan.stub(:custom_loan_data).and_return data

      expect(helper.custom_loan_data(loan)).to eq(data)
    end

    it "should return a new custom data for a loan that does not have one" do
      loan = Master::Loan.first  # need a real instance for this
      expect(loan.custom_loan_data).to be_nil

      cd = helper.custom_loan_data(loan)
      expect(cd).to be_a(Master::LoanDetails::CustomLoanData)
      expect(cd).not_to be_new_record
    end

  end

end
