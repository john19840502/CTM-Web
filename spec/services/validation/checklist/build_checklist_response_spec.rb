require 'spec_helper'

describe Validation::Checklist::BuildChecklistResponse do

  it "should return a stub response for nil definition" do
    ret_val = Validation::Checklist::BuildChecklistResponse.call nil
    expect(ret_val[:sections]).to be_empty
    expect(ret_val[:conclusion]).to eq "NOT STARTED"
    expect(ret_val[:warnings]).to be_empty
    expect(ret_val[:started]).to be_falsey
    expect(ret_val[:completed]).to be_falsey
    expect(ret_val[:status]).to eq "fail"
  end

  it "should return a stub response for nil checklist" do
    definition = double
    allow(definition).to receive(:checklist)
    ret_val = Validation::Checklist::BuildChecklistResponse.call definition
    expect(ret_val[:sections]).to be_empty
    expect(ret_val[:conclusion]).to eq "NOT STARTED"
    expect(ret_val[:warnings]).to be_empty
    expect(ret_val[:started]).to be_falsey
    expect(ret_val[:completed]).to be_falsey
    expect(ret_val[:status]).to eq "fail"
  end

  context "with valid loan" do

    let(:response) { 
      checklist = double
      loan = double
      # not actually testing interaction with loan, just making it run
      allow(loan).to receive(:channel).and_return(Channel.wholesale.identifier)
      allow(loan).to receive(:is_fha?).and_return(false)
      allow(loan).to receive(:is_va?).and_return(false)
      loan.stub_chain(:lock_loan_datum) { nil }
      loan.stub_chain(:custom_fields, :lender_paid_mi?).and_return(false)
      allow(loan).to receive(:mini_corr_loan?).and_return(false)
      allow(loan).to receive(:is_usda?).and_return(false)
      allow(loan).to receive(:loan_num).and_return(123456789)
      allow(loan).to receive(:is_locked?).and_return(false)
      allow(checklist).to receive(:loan).and_return(loan)
      allow(checklist).to receive(:checklist_answers).and_return([])
      definition = RegistrationChecklistDefinition.new checklist
      
      Validation::Checklist::BuildChecklistResponse.call definition
    }

    it "populates the registration questions" do
      sections = response[:sections]
      expect(sections.length).to eq 1
      expect(sections.first[:section]).to eq "Registration Checklist"
    end

    it "calculates conclusion" do
      conclusion = response[:conclusion]
      expect(conclusion).to eq "Incomplete"
    end

    it "provides stubs" do
      expect(response[:warnings]).to be_empty
      expect(response[:started]).to be_truthy
      expect(response[:completed]).to be_falsey
    end

    it "calculates status" do
      expect(response[:status]).to eq "fail"
    end

  end

end