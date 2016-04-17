require 'spec_helper'

RSpec.describe InitialDisclosureTracking do
  let(:loan) { Master::Loan.new }
  before do
    subject.stub loan: loan
  end

  describe 'update_visibility!' do
    before do
      subject.stub :save!
    end

    context "CTMWEB-4754 fix" do
      it "should become visible if it is not visible" do
        subject.wq_loan_status = 'OnHold'
        subject.visible = false
        subject.update_visibility!
        expect(subject.visible).to eq true
      end
    end

    context "when the status is completed" do
      before do
        subject.wq_loan_status = 'Completed'
        loan.stub initial_disclosure_requested_value: "Y"
        loan.stub initial_disclosure_request_completed?: true
        loan.stub docmagic_disclosure_request_created?: true
      end

      it "should remain false if it was already false" do
        subject.visible = false
        loan.stub initial_disclosure_request_completed?: false # would normally make it stay true
        subject.update_visibility!
        expect(subject.visible).to eq false
      end

      it "should become not visible if the disclosures are requested and the instance is complete" do
        subject.update_visibility!
        expect(subject.visible).to eq false
        expect(subject).to have_received(:save!)
      end

      it "should remain visible if the disclosre request is not Y" do
        [ 'N', nil ].each do |v|
          loan.stub initial_disclosure_requested_value: v
          subject.update_visibility!
          expect(subject.visible).to eq true
        end
      end

      it "should remain visible if the disclosure request is not complete" do
        loan.stub initial_disclosure_request_completed?: false
        subject.update_visibility!
        expect(subject.visible).to eq true
      end

      it "should remain visible if the docmagic request is not created" do
        loan.stub docmagic_disclosure_request_created?: false
        subject.update_visibility!
        expect(subject.visible).to eq true
      end
    end

    context "when the status is Rejected" do
      before do
        subject.wq_loan_status = 'Rejected'
      end

      it "should stay non-visible if it was already false" do
        subject.visible = false
        loan.pipeline_loan_status_description = "foo"
        subject.update_visibility!
        expect(subject.visible).to eq false
      end

      it "should become not visible if the status is right" do
        loan.pipeline_loan_status_description = "Cancelled"
        subject.stub loan_archived?: true
        subject.update_visibility!
        expect(subject.visible).to eq false
      end

      it "should stay visible if the loan is not archived" do
        subject.stub loan_archived?: false
        loan.pipeline_loan_status_description = "Cancelled"
        subject.update_visibility!
        expect(subject.visible).to eq true
        expect(subject).to have_received(:save!)
      end

      it "should stay visible if the status is wrong" do
        loan.pipeline_loan_status_description = "fsljf"
        subject.update_visibility!
        expect(subject.visible).to eq true
      end
    end

    context "when the status is non trid" do
      before do
        subject.wq_loan_status = "Non-TRID"
      end

      it "should always be not visible" do
        subject.update_visibility!
        expect(subject.visible).to eq false
      end
    end

  end
end
