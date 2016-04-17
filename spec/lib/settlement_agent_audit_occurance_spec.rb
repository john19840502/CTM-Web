require 'spec_helper'

describe SettlementAgentAuditOccurance do
  before do
    SettlementAgentAudit.delete_all
  end
  audit_params = { loan_id: "12345", settlement_agent: "Settlement Agent Corp", address_completed: 'Yes' , all_boxes_completed: 'Yes',
          sectionb_page1_completed: 'Yes' , tolerance_cure_necessary: 'Yes', seller_concession_appear: 'Yes', 
          cash_from_borrower_match: 'Yes', correct_fees_800section_credits: 'Yes', correct_fees_900section: 'Yes', 
          agent_charges_match_approved: 'Yes', agent_show_correct_mbfees: 'Yes', agent_changes_page2_hud_fees: 'No', 
          gfe_match_final_gfe: 'Yes', hud1_side_match_page2_hud: 'Yes', loan_terms_section_completed_acc: 'Yes', 
          new_costs_cure_for_agent_completion: 'No', seller_credit_changed: 'No', realtor_credit_changed: 'No', lender_credit_changed: 'No' }

  subject {SettlementAgentAudit}
  
  describe "Acceptable answers for HUD" do
    it "should only increment hud value when all are expected answer" do
      audit = subject.create(audit_params,without_protection: true)
      expect(audit.hud_review).to eq(1)
      expect(audit.agent_page1).to eq 'Yes'
      expect(audit.agent_page2).to eq 'Yes'
      expect(audit.agent_page3).to eq 'Yes'
    end
  end
  describe "It should take multiple options for some questions" do
    let(:params) {audit_params.merge({seller_concession_appear: 'NA', cash_from_borrower_match: 'NA', agent_show_correct_mbfees: 'NA'})}
    let(:audit) {subject.create(params, without_protection: true)}

    it {expect(audit.agent_page1_count).to eq 0 }
    it {expect(audit.cash_from_borrower_match_occurance).to eq 0}
    it {expect(audit.agent_page1).to eq 'Yes'}
    it {expect(audit.agent_page2).to eq 'Yes'}
    it {expect(audit.agent_page3).to eq 'Yes'}
  end

  context "when hud has sub questions Agent page result should depend on sub questions answers" do
    it "should calculate the occurrence for sub questions along with HUD page AND change the value for agent page to invalid answer" do
      params = audit_params.merge({address_completed: 'Yes', all_boxes_completed: 'No', hud1_side_match_page2_hud: 'No'})
      audit = subject.create(params, without_protection: true)
      expect(audit.hud_review).to eq 1
      expect(audit.all_boxes_completed_occurance).to eq 1
      expect(audit.address_completed_occurance).to eq 0
      expect(audit.agent_page1).to eq 'No'
      expect(audit.agent_page1_count).to eq 1
      expect(audit.hud1_side_match_page2_hud).to eq 'No'
      expect(audit.hud1_side_match_page2_hud_occurance).to eq 1
      expect(audit.agent_page3_count).to eq 1
    end

    it "should change the Agent page result to YES/NO based on the sub questions" do
      params = audit_params.merge({all_boxes_completed: 'No'})
      audit = subject.create(params, without_protection: true)
      expect(audit.all_boxes_completed).to eq 'No'
      expect(audit.agent_page1).to eq 'No'
      expect(audit.agent_page2).to eq 'Yes'

      params1 = audit.attributes 
      params1.delete("id")
      params = params1.merge({all_boxes_completed: 'Yes'})
      audit = subject.create(params, without_protection: true)
      expect(audit.agent_page1).to eq 'Yes'
      expect(audit.agent_page2).to eq 'Yes'
    end

  end

  context "When answers are not expected" do
    it "should increase the occurance and hud_review when the answer is not expected answer" do
      params = audit_params.merge({cash_from_borrower_match: 'No'})
      audit = subject.create(params,without_protection: true)
      expect(audit.agent_page1_count).to eq(1)
      expect(audit.agent_page1).to eq('No')
      expect(audit.cash_from_borrower_match_occurance).to eq(1)
      expect(audit.hud_review).to eq 1
    end

    it "should increment the occurrence and hud review for HUD questions (1..8) by checking sub questions" do
      params = audit_params.merge({seller_concession_appear: 'No', seller_concession_appear_occurance: 1, agent_page1_count: 1, hud_review: 1})
      audit = subject.create(params, without_protection: true)
      expect(audit.agent_page1_count).to eq 2
      expect(audit.seller_concession_appear_occurance).to eq 2
      expect(audit.hud_review).to eq 2
    end

    it "should increment the sub question occurance and the main page occurance when the answer is unexpected" do
      params = audit_params.merge({address_completed: 'No', all_boxes_completed: 'No', all_boxes_completed_occurance: 1, tolerance_cure_necessary: 'No', cash_from_borrower_match: 'Yes'})
      audit = subject.create(params, without_protection: true)
      expect(audit.address_completed_occurance).to eq 1
      expect(audit.all_boxes_completed_occurance).to eq 2
      expect(audit.agent_page1).to eq 'No'
      expect(audit.agent_page1_count).to eq 3
      expect(audit.tolerance_cure_necessary).to eq 'No'
      expect(audit.tolerance_cure_necessary_occurance).to eq 1
      expect(audit.hud_review).to eq 1

      params = audit.attributes
      params.delete("id")
      audit = subject.create(params, without_protection: true)
      expect(audit.address_completed_occurance).to eq 2
      expect(audit.all_boxes_completed_occurance).to eq 3
      expect(audit.cash_from_borrower_match_occurance).to eq 0
      expect(audit.tolerance_cure_necessary_occurance).to eq 2
      expect(audit.agent_page1_count).to eq 6
      expect(audit.hud_review).to eq 2
    end

    describe "Behaviour of questions which affect HUD only once when not valid" do
      it "should increase the occurance once when changed_closing_dates is not as expected" do
        params = audit_params.merge({changed_closing_dates: "Yes"})
        audit = subject.create(params,without_protection: true)
        expect(audit.changed_closing_dates_occurance).to eq(1)
        expect(audit.hud_review).to eq 1
      end
      it "should not increment hud review and occurance for questions 9-19 for further reviews" do
        params = audit_params.merge({changed_closing_dates: "Yes", changed_closing_dates_occurance: 1, hud_review: 1})
        audit = subject.create(params,without_protection: true)
        expect(audit.changed_closing_dates_occurance).to eq(1)
        expect(audit.hud_review).to eq(1)
      end
    end
  end
end