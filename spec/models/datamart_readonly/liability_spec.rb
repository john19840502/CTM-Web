require 'spec_helper'

describe Liability do
  subject { build_stubbed :liability }
    let(:borrower) {build_stubbed(:borrower, borrower_id: 'BRW1', equifax_credit_score: 670, experian_credit_score: 660, trans_union_credit_score: 650)}
  
  describe "subordinate financing" do
    let(:reo_property) {FactoryGirl.build_stubbed(:reo_property, subject_indicator: false)}

    context 'when a li has subordinate financing' do
      it "MortgageLoan, subjectloanresubordinationindicator is true, has reo_id, subject_indicator is true, subordinate_lien_amount > 0 " do
        reo_property.stub(:subject_indicator).and_return(true)
        subject.stub_chain(:reo_property).and_return(reo_property)
        subject.stub_chain(:loan_general, :subordinate_lien_amount).and_return(1000)
        subject.stub_chain(:loan_general, :undrawn_heloc_amount).and_return(0)
        subject.liability_type = "MortgageLoan"
        subject.subject_loan_resubordination_indicator = true
        subject.subordinate?.should eq("Yes")
      end      

      it "HELOC, subjectloanresubordinationindicator is true, has reo_id, subject_indicator is true, subordinate_lien_amount > 0 " do
        reo_property.stub(:subject_indicator).and_return(true)
        subject.stub_chain(:reo_property).and_return(reo_property)
        subject.stub_chain(:loan_general, :subordinate_lien_amount).and_return(1000)
        subject.stub_chain(:loan_general, :undrawn_heloc_amount).and_return(0)
        subject.liability_type = "HELOC"
        subject.subject_loan_resubordination_indicator = true
        subject.subordinate?.should eq("Yes")
      end      

      it "subordinate lien amount is greater than zero" do
        subject.stub_chain(:reo_property).and_return(nil)
        subject.liability_type = nil
        subject.subject_loan_resubordination_indicator = nil
        subject.stub_chain(:loan_general, :subordinate_lien_amount).and_return(1000)
        subject.stub_chain(:loan_general, :undrawn_heloc_amount).and_return(0)
        subject.subordinate?.should eq("Yes")
      end      

      it "subordinate undrawn heloc  amount is greater than zero" do
        subject.stub_chain(:reo_property).and_return(nil)
        subject.liability_type = nil
        subject.subject_loan_resubordination_indicator = nil
        subject.stub_chain(:loan_general, :subordinate_lien_amount).and_return(0)
        subject.stub_chain(:loan_general, :undrawn_heloc_amount).and_return(1000)
        subject.subordinate?.should eq("Yes")
      end      
    end

    context 'when a loan does not subordinate financing' do
      it "subjectloanresubordinationindicator is true, has reo_id, subject_indicator is false, subordinate_lien_amount is 0 " do
        subject.liability_type = "MortgageLoan"
        subject.stub_chain(:reo_property).and_return(nil)
        subject.stub_chain(:loan_general, :subordinate_lien_amount).and_return(0)
        subject.stub_chain(:loan_general, :undrawn_heloc_amount).and_return(0)
        subject.subordinate?.should eq("No")
      end
    end

    context "#non_occupying_borrower?" do
      before do
        subject.liability_type = "MortgageLoan"
        allow(subject).to receive(:borrower).and_return borrower
        borrower.stub_chain(:intent_to_occupy?).and_return("No")
        borrower.stub_chain(:occupying?).and_return(false)
      end
 
      it "returns true if the borrower is non occupying" do
        expect(subject.non_occupying_borrower?).to eq(true)
      end
 
      it "returns false if the borrower is occupying" do
        borrower.stub_chain(:intent_to_occupy?).and_return("Yes")
        expect(subject.non_occupying_borrower?).to eq(false)
      end
    end

    context "#holder_title?" do
      ['Taxes','Insurance','T&I','T & I','TandI','T and I','TaXes','The quick taxing fox','tax','ins','Ins','Tax'].each do |input|
        it "Returns true if holder_name is '#{input}'" do
          subject.liability_type = "MortgageLoan"
          subject.holder_name = input
          expect(subject.holder_title?).to eq(true)
        end
      end

      ['alpha','Taixes','foo','T I'].each do |input|
        it "Returns falseif holder_name is '#{input}'" do
          subject.liability_type = "MortgageLoan"
          subject.holder_name = input
          expect(subject.holder_title?).to eq(false)
        end
      end
    end
  end
end
