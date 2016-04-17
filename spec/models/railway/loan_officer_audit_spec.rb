require 'spec_helper'

describe LoanOfficerAudit do

	subject { LoanOfficerAudit }
	before do
		subject.delete_all
	end

	describe ".create_or_update_loan_officer_audit" do
		context "When the loan is valid" do
			loan =Loan.first
			it " should check for loan and loan_general" do
				subject.create_or_update_loan_officer_audit(loan)
				loan.present?.should be true
				loan.loan_general.present?.should be true	
			end

			let(:originator_id) {loan.loan_general.originator.id}
			
			it "should create LoanOfficerAudit if there are no audits" do
				subject.create_or_update_loan_officer_audit(loan)
				subject.last.reload.loan_event_id.to_s.should eq(loan.id)
				subject.last.reload.loan_id.should eq(loan.id)
				subject.last.reload.event_date.to_date.should == DateTime.now.to_date
				subject.last.reload.datamart_user_id.should eq(originator_id)
			end
			
			it "should create another audit for different originator_id" do
				subject.create_or_update_loan_officer_audit(loan)
				loan.loan_general.originator.stub id: 100
				subject.create_or_update_loan_officer_audit(loan)
				subject.last.reload.loan_event_id.to_s.should eq(loan.id)
				subject.last.reload.loan_id.should eq(loan.id)
				subject.last.reload.event_date.to_date.should == DateTime.now.to_date
				subject.last.reload.datamart_user_id.should eq(originator_id)	
			end

			it "should not create LoanOfficerAudit if audit exists with same originator_id" do
				subject.create!({:datamart_user_id => 100, :loan_id => loan.id}, without_protection: true)
				loan.loan_general.originator.stub id: 100
				expect(subject.create_or_update_loan_officer_audit(loan)).to be_nil
			end

		end
		context "when loan or loan_general is nil" do
			it "should return nil if loan is nil" do
				expect( subject.create_or_update_loan_officer_audit(nil)).to be_nil
			end

			it "should return nil if the loan_general is nil" do
				loan = Loan.first
				loan.stub(loan_general: nil)
				expect(subject.create_or_update_loan_officer_audit(loan)).to be_nil
			end
		end
	end
end
