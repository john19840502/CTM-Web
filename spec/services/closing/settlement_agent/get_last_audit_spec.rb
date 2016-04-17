require 'spec_helper'

describe Closing::SettlementAgent::GetLastAudit do
  let(:loan) {Loan.new}
  let(:fail_response) {{status: "fail", conclusion: "FAIL"}}
  let(:pass_response) {{status: "pass", conclusion: "PASS"}}

  describe ".conclusion" do
    context "When the loan is not trid loan" do
      before{loan.stub trid_loan?: false}
      it "should return PASS when the answers are as expected" do
        audit = create_agent
        expect(subject.class.conclusion(loan, audit)).to eq(pass_response)
      end

      it "should return fail response when answers are not as expected" do
        audit = create_agent
        audit.agent_page2 = 'No'
        expect(subject.class.conclusion(loan, audit)).to eq(fail_response)
      end
    end

    context "when loan is a trid loan" do
      before{ loan.stub trid_loan?: true } 
      it "should return the passing response when the answers are matching" do
        trid_audit = create_trid_agent
        expect(subject.class.conclusion(loan, trid_audit)).to eq(pass_response)
      end

      it "should return the failing response when the answers do not match" do
        trid_audit = create_trid_agent
        trid_audit.cd_page1_correct = "No"
        expect(subject.class.conclusion(loan, trid_audit)).to eq(fail_response)
      end
    end
  end

  def create_agent 
    SettlementAgentAudit.new({agent_page1: 'Yes', agent_page2: 'Yes', agent_page3: 'Yes', seller_credit_changed: 'No', realtor_credit_changed: 'No', lender_credit_changed: 'No'}, without_protection: true )
  end

  def create_trid_agent 
    SettlementAgentTridAudit.new({cd_page1_correct: 'Yes' , cd_page2_correct: 'Yes' , cd_page3_correct: 'Yes' , cd_page4_correct: 'Yes' , cd_page5_correct: 'Yes' , cd_page6_correct: 'Yes'}, without_protection: true)
  end
end