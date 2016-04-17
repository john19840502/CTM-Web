require 'spec_helper'

describe SettlementAgentMonthlyCalculation do
  subject { SettlementAgentMonthlyCalculation }
  let(:audit_service) {Closing::SettlementAgent::ReportData}
  before do
    subject.delete_all
  end

  context ".create_monthly_calculation_entries " do
    it "should make single entry for settlement agent for every month" do
      agent1_audits = FactoryGirl.create_list(:settlement_agent_audit, 3, created_at: Date.new(2015,1,1), settlement_agent: "Closing_agent1" )
      agent2_audits = FactoryGirl.create_list(:settlement_agent_audit, 2, created_at: Date.new(2015,1,1), settlement_agent: "Closing_agent2" )
      agent3_audits = FactoryGirl.create_list(:settlement_agent_audit, 3, created_at: Date.new(2015,1,1), settlement_agent: "Closing_agent3" )
      audits = agent1_audits + agent2_audits + agent3_audits
      audit_service.should_receive(:get_monthly_audits).and_return audits
      subject.create_monthly_calculation_entries

      expect(subject.count).to eq(3)
      expect(subject.where(:settlement_agent => "Closing_agent1").first.hud_review).to eq(3) 
      expect(subject.where(:settlement_agent => "Closing_agent2").first.loans_funded).to eq(2)
    end

    it "should create entry for escrow agent, if escrow agent not present create entry for settlement agent" do
      agent1_audits = FactoryGirl.create_list(:settlement_agent_audit, 2, created_at: Date.new(2015,1,1), settlement_agent: "Closing_agent1" )
      agent2_audits = FactoryGirl.create_list(:settlement_agent_audit, 5, created_at: Date.new(2015,1,1), settlement_agent: "Closing_agent2", escrow_agent_id: 33, hud_review: 2 )
      audits = agent1_audits + agent2_audits
      audit_service.should_receive(:get_monthly_audits).and_return audits
      subject.create_monthly_calculation_entries

      expect(subject.count).to eq(2)
      expect(subject.where(:settlement_agent => "Closing_agent1").first.loans_funded).to eq(2) 
      expect(subject.where(escrow_agent_id: 33).first.settlement_agent).to be_nil
      expect(subject.where(escrow_agent_id: 33).first.hud_review).to eq(10)
    end
  end
end
