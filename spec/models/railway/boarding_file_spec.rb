require 'spec_helper'

describe BoardingFile do
	before do
		BoardingFile.delete_all
	end
	subject { BoardingFile.create!(name: "boardfile") }
		
	describe "#board" do
		it "should create a LoanBoarding with valid loan" do
			loan = Master::Loan.first
			subject.board(loan)
			subject.save!
			subject.reload.loan_boardings.first.loan.should eq(loan)
			loan.reload.boarding_files.should include subject
		end
	end
end
