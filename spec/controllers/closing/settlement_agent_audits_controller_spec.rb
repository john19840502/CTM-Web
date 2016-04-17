require 'spec_helper'

describe Closing::SettlementAgentAuditsController do 
  before do
    fake_rubycas_login
    SettlementAgentAudit.delete_all
  end

  describe "get :last_audit" do
    let(:loan) {Loan.new}
    let(:loan_general) { build_stubbed :loan_general }
    let(:closing_agent) {ClosingAgent.new()}
    
    before do
      loan.stub(:loan_general) {loan_general}
      allow(loan).to receive(:trid_loan?).and_return(false)
      Loan.stub(:find_by_loan_num).with('12345').and_return(loan)
    end

    it "should assign the loan" do
      get :last_audit, id: '12345', format: :json
      expect(response.status).to eq(200)
      expect(assigns(:loan)).to eq(loan)
    end

    it "should create new audit with closing agent data" do
      closing_agent.stub(agent_type: "TitleCompany", name: "Closing_agent_company" )
      loan.loan_general.closing_agents.should_receive(:where).and_return([closing_agent])

      get :last_audit, id: '12345', format: :json

      expect(assigns(:last_audit).settlement_agent).to eq("Closing_agent_company")
      expect(assigns(:last_audit)).to be_a SettlementAgentAudit
      expect(assigns(:last_audit).new_record?).to be_truthy
    end

    it "should fetch the last audit for the loan" do
      audits = FactoryGirl.create_list(:settlement_agent_audit, 3, created_at: Date.new(2015,1,1), settlement_agent: "Closing_agent1" )
      loan.stub settlement_agent_audits: audits
      get :last_audit, id: '12345', format: :json

      expect(assigns(:last_audit).persisted?).to be_truthy
      expect(assigns(:last_audit)).to be_a SettlementAgentAudit
      expect(assigns(:last_audit).settlement_agent).to eq("Closing_agent1")
    end
  end

  describe "get :create" do
    let(:get_audit) {Closing::SettlementAgent::GetLastAudit}
    let(:params) {{id: 2162, loan_id: "98765", settlement_agent: "Absolute Title, Inc.", escrow_agent_id: nil,address_completed:"Yes",address_completed_occurance:0, all_boxes_completed: 'Yes', all_boxes_completed_occurance: 0, sectionb_page1_completed: 'Yes', sectionb_page1_completed_occurance: 0, tolerance_cure_necessary: 'Yes', tolerance_cure_necessary_occurance: 0, seller_concession_appear: 'Yes', seller_concession_appear_occurance: 0, cash_from_borrower_match: 'Yes', cash_from_borrower_match_occurance: 0, correct_fees_800section_credits:"Yes",correct_fees_800section_credits_occurance:0, correct_fees_900section:"Yes",correct_fees_900section_occurance: 0, agent_charges_match_approved: 'Yes', agent_charges_match_approved_occurance: 0, agent_show_correct_mbfees: 'Yes', agent_show_correct_mbfees_occurance: 0, agent_changes_page2_hud_fees: 'Yes', agent_changes_page2_hud_fees_occurance: 0, gfe_match_final_gfe: 'Yes', gfe_match_final_gfe_occurance: 0, hud1_side_match_page2_hud: 'Yes', hud1_side_match_page2_hud_occurance: 0, loan_terms_section_completed_acc: 'Yes', loan_terms_section_completed_acc_occurance: 0, new_costs_cure_for_agent_completion: 'Yes', new_costs_cure_for_agent_completion_occurance: 0,
     seller_credit_changed:"Yes",seller_credit_changed_occurance:2,realtor_credit_changed:"No",realtor_credit_changed_occurance:0,lender_credit_changed:"No",lender_credit_changed_occurance:0,fee_increase:"No",fee_increase_occurance:0,fee_decrease:"No",fee_decrease_occurance:0,added_apr_fees:"No",added_apr_fees_occurance:0,changed_closing_docs:"No",changed_closing_docs_occurance:0,changed_legal_docs:"No",changed_legal_docs_occurance:0,changed_power_of_attorney:"No",changed_power_of_attorney_occurance:0,changed_doc_for_trust:"No",changed_doc_for_trust_occurance:0,incorrectly_date_docs:"No",incorrectly_date_docs_occurance:0,changed_closing_dates:"No",changed_closing_dates_occurance:0,followed_closing_instructions:"Yes",followed_closing_instructions_occurance:0,changed_nortc_correctly:"NA",changed_nortc_correctly_occurance:0,notification_pending_litigation:"No",notification_pending_litigation_occurance:0,pay_off_liens:"Yes",pay_off_liens_occurance:0,comments:nil,audited_by:nil,hud_review:2,audited_by_suspense:nil}}
    
    it "should create new audit with the parameters passed" do
      allow(get_audit).to receive(:conclusion).and_return({status: 'pass', conclusion: "PASS"})
      post :create, params.merge(format: :json)
      expect(response.status).to eq(200)
      expect(assigns(:settlement_agent_audit).persisted?).to be_truthy
      expect(assigns(:settlement_agent_audit).seller_credit_changed_occurance).to eq(3)
    end
  end
end