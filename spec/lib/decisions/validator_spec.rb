require 'spec_helper'

describe Decisions::Validator do 
  let(:loan) {Loan.new} 
  let(:decision) { new_validator('registration') }
  before do
    Bpm::LoanValidationEvent.delete_all
    loan_general = FactoryGirl.build_stubbed(:loan_general)
    loan.stub(:loan_general) { loan_general }
  end

  initial_disclosure_flows = Decisions::Flow::FLOWS.select{|a, b| b[:validate] == "initial_disclosure"}.map{|a,b| a.to_s}
  registration_flows       = Decisions::Flow::FLOWS.select{|a, b| b[:validate] == "registration"}.map{|a,b| a.to_s}
  underwriter_flows        = Decisions::Flow::FLOWS.select{|a, b| b[:validate] == "underwriter"}.map{|a,b| a.to_s}
  preclosing_flows         = Decisions::Flow::FLOWS.select{|a, b| b[:validate] == "preclosing"}.map{|a,b| a.to_s}
  closing_flows            = Decisions::Flow::FLOWS.select{|a, b| b[:validate] == "closing"}.map{|a,b| a.to_s}

  context 'flows based on validation type' do
    it 'should return flows for the specified validation screen only' do
      res = new_validator('registration')
      expect(res.flows).not_to include 'appraisal_acceptance'
      expect(res.flows).not_to include 'le_box_a'
    end
  end

  describe ".extract_flows" do 
    it 'should not include AUS Registration Acceptance for underwriter' do
      res = new_validator('underwriter')
      expect(res.flows).not_to include 'ausreg'
    end

    it 'should not include AUS Registration Acceptance for preclosing' do
      res = new_validator('preclosing')
      expect(res.flows).not_to include 'ausreg'
    end

    it 'should not include AUS Registration Acceptance for closing' do
      res = new_validator('closing')
      expect(res.flows).not_to include 'ausreg'
    end

    it "should return the valid flows for validation type initial_disclosure" do
      validation = new_validator('initial_disclosure')
      expect(validation.flows).to include(*initial_disclosure_flows)
    end

    it "should include the valid flows for the validation type registration" do
      validation = new_validator('registration')
      expect(validation.flows).to include(*registration_flows)
    end

    it "should include all flows of initial_disclosure, registration and underwriter flows for underwrier validation type" do
      validation = new_validator('underwriter')
      expect(validation.flows).to include(*initial_disclosure_flows - ['le_box_b','le_box_c','le_box_e_acceptance','le_box_g','le_box_a','le_page_three','application_date_compliance', 'compensation_acceptance', 'le_box_j_acceptance'])
      expect(validation.flows).to include(*registration_flows - ['ausreg','intent_to_proceed', 'tbd_policy_acceptance'])
      expect(validation.flows).to include(*underwriter_flows)
    end

    it "should include right flows for preclosing" do
      validation = new_validator('preclosing')
      expect(validation.flows).to include(*initial_disclosure_flows - ['le_box_b','le_box_c','le_box_e_acceptance','le_box_g','le_box_a','le_page_three','application_date_compliance', 'compensation_acceptance', 'le_box_j_acceptance'])
      expect(validation.flows).to include(*registration_flows - ['ausreg','intent_to_proceed', 'tbd_policy_acceptance'])
      expect(validation.flows).to include(*underwriter_flows)
      expect(validation.flows).to include(*preclosing_flows)
    end

    it "should include right flows for closing" do
      validation = new_validator('closing')
      expect(validation.flows).to include(*initial_disclosure_flows - ['le_box_b','le_box_c','le_box_e_acceptance','le_box_g','le_box_a','le_page_three','application_date_compliance', 'compensation_acceptance', 'le_box_j_acceptance'])
      expect(validation.flows).to include(*registration_flows - ['ausreg','intent_to_proceed', 'tbd_policy_acceptance'])
      expect(validation.flows).to include(*underwriter_flows)
      expect(validation.flows).to include(*preclosing_flows)
      expect(validation.flows).to include(*closing_flows)
    end
  end

  describe ".execute" do
    it "should return validation response" do
      respond_to(:execute_validation).with(4)
      decision.stub(:execute_validation) { validation_response(["This is error", "another error"], ["Warning for this", "Second warning"]) }
      expect(decision.execute).to include({:errors=>["This is error", "another error"], :warnings=>["Warning for this", "Second warning"], :conclusion=>"Acceptable"})
    end

    it "should also execute the ruby rules for underwriter" do
      decision = new_validator('underwriter')
      decision.stub(:execute_validation) { validation_response(["This is error", "another error"], ["Warning for this", "Second warning"]) }
      decision.execute
      expect(Bpm::LoanValidationEvent.last.loan_validation_flows.map(&:name)).to include("uw validation")
    end
  end

  describe ".execute_validation" do
    let(:event) {Bpm::LoanValidationEvent.new}
    let(:fact_type) {Decisions::Facttype.new('dti', {loan: loan, event_id: event.id})}
    let(:new_flow)  { Decisions::Flow.new('dti', fact_type) }
    
    it "should save the validation result in Bpm::StatsRecorder" do
      allow(Decisions::Facttype).to receive(:new).and_return(fact_type)
      allow(fact_type).to receive(:execute).and_return({"LowestFICOScore"=>817, "LoanProductName"=>"C20FXD"})

      allow(Decisions::Flow).to receive(:new).and_return(new_flow)
      allow(new_flow).to receive(:execute).and_return( validation_response(["This is error"], []))
      
      decision.execute
      expect(Bpm::LoanValidationEvent.last.validation_type).to eq 'registration'
      expect(Bpm::LoanValidationEvent.last.loan_validation_flows.map(&:name)).to include(*registration_flows)
    end
  end

  def new_validator type
    Decisions::Validator.new(type, loan)
  end

  def validation_response errors, warnings
    {
      :errors => errors ,
      :warnings => warnings,
      :conclusion => "Acceptable"
    }
  end
end
