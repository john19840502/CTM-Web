require 'spec_helper'

describe PurchasedLoan do
  subject { PurchasedLoan }
  before do
    subject.delete_all
    LoanComplianceEvent.delete_all
  end

  let!(:unreported_loan) { PurchasedLoan.create({cpi_number: '123456789', reported: false}, without_protection: true) }
  let!(:reported_loan) { PurchasedLoan.create({cpi_number: '6789101023', reported: true}, without_protection: true) }

  describe '#create_events' do
    it "should create loan compliance event for unreported purchased loan" do
      subject.create_events
      subject.count.should == 2
      LoanComplianceEvent.count.should == 1
    end
  end
end
