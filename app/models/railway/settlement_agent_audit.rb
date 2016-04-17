class SettlementAgentAudit < DatabaseRailway
  include AgentAudit
 
  belongs_to :loan
  belongs_to :escrow_agent
  belongs_to :closing_agent, foreign_key: :settlement_agent
  
  validates_presence_of :address_completed, :all_boxes_completed, :sectionb_page1_completed, :tolerance_cure_necessary, :seller_concession_appear, :cash_from_borrower_match, :correct_fees_800section_credits, :correct_fees_900section, :agent_charges_match_approved, :agent_show_correct_mbfees, :agent_changes_page2_hud_fees, :gfe_match_final_gfe, :hud1_side_match_page2_hud, :loan_terms_section_completed_acc, :new_costs_cure_for_agent_completion, :seller_credit_changed, :realtor_credit_changed, :lender_credit_changed #, :agent_page1, :agent_page2, :agent_page3, 
  after_create :calculate_occurance

  # occ_cal represents the Question's each occurance of wrong needs to be counted or not. If it is false only one occurrence of wrong answer is counted.
  # hud: defines if the hud_review is counted for the particular question. If yes each time question is wrong hud review is counted

  AUDIT_QUESTIONS = { :agent_page1 => { expected: 'Yes', unexpected: 'No', occ_cal: true, hud: true, 
        :checks => { address_completed: ['Yes'], all_boxes_completed: ['Yes'], sectionb_page1_completed: ['Yes'], tolerance_cure_necessary: ['Yes', 'NA'], seller_concession_appear: ['Yes', 'NA'], cash_from_borrower_match: ['Yes', 'NA']} },
    :agent_page2                => { expected: 'Yes', unexpected: 'No', occ_cal: true, hud: true, :checks => { correct_fees_800section_credits: ['Yes'], correct_fees_900section: ['Yes'], agent_charges_match_approved: ['Yes'], agent_show_correct_mbfees: ['Yes', 'NA'], agent_changes_page2_hud_fees: ['No']}},
    :agent_page3                => { expected: 'Yes', unexpected: 'No', occ_cal: true, hud: true, :checks => { gfe_match_final_gfe: ['Yes'], hud1_side_match_page2_hud: ['Yes'], loan_terms_section_completed_acc: ['Yes'], new_costs_cure_for_agent_completion: ['No']}},
    :seller_credit_changed      => { expected: 'No', occ_cal: true, hud: true, :checks => {}},
    :realtor_credit_changed     => { expected: 'No', occ_cal: true, hud: true, :checks => {}},
    :lender_credit_changed      => { expected: 'No', occ_cal: true, hud: true, :checks => {}},
    :fee_increase               => { expected: 'No', occ_cal: false, hud: true, :checks => {}},
    :fee_decrease               => { expected: 'No', occ_cal: false, hud: true, :checks => {}},
    :added_apr_fees             => { expected: 'No', occ_cal: false, hud: false, :checks => {}},
    :changed_closing_docs       => { expected: "No", occ_cal: false, hud: false, :checks => {}},
    :changed_legal_docs         => { expected: "No", occ_cal: false, hud: false, :checks => {}},
    :changed_power_of_attorney  => { expected: "No", occ_cal: false, hud: false, :checks => {}},
    :changed_doc_for_trust      => { expected: "No", occ_cal: false, hud: false, :checks => {}},
    :incorrectly_date_docs      => { expected: "No", occ_cal: false, hud: false, :checks => {}},
    :changed_closing_dates      => { expected: "No", occ_cal: false, hud: false, :checks => {}},
    :agent_executed_documents_correctly => {expected: 'Yes', occ_cal: false, hud: false, :checks => {}},
    :followed_closing_instructions      => { expected: "Yes", occ_cal: false, hud: false, :checks => {}},
    :changed_nortc_correctly     => { expected:"NA", occ_cal:false, hud: false, :checks => {}},
    :closing_conditions_been_met => { expected: 'Yes', occ_cal:false, hud: false, :checks => {} },
    :agent_sent_proper_doc_fundingauth  => { expected: 'Yes', occ_cal:false, hud: false, :checks => {}},
    :agent_disburse_loan_properdate     => { expected: 'Yes', occ_cal:false, hud: false, :checks => {}},
    :notification_pending_litigation    => { expected: "No", occ_cal: false, hud: false, :checks => {}},
    :pay_off_liens                => { expected: "Yes", occ_cal: false, hud: false, :checks => {}}
  }

  def total_occurance
    total_occurance = self.total_hud_occurance + self.other_occurance_count
  end

  def other_occurance_count
    added_apr_fees_occurance + changed_closing_docs_occurance + changed_legal_docs_occurance + changed_power_of_attorney_occurance + changed_doc_for_trust_occurance + incorrectly_date_docs_occurance + changed_closing_dates_occurance + followed_closing_instructions_occurance + changed_nortc_correctly_occurance + notification_pending_litigation_occurance + pay_off_liens_occurance + agent_executed_documents_correctly_occurance.to_i + closing_conditions_been_met_occurance.to_i + agent_sent_proper_doc_fundingauth_occurance.to_i + agent_disburse_loan_properdate_occurance.to_i
  end

  def total_hud_occurance
    total_count = agent_page1_occurance + agent_page2_occurance + agent_page3_occurance + agent_page1_count + agent_page2_count + agent_page3_count + seller_credit_changed_occurance + realtor_credit_changed_occurance + lender_credit_changed_occurance + fee_increase_occurance + fee_decrease_occurance 
  end

  private
  
  def calculate_occurance
    SettlementAgentAuditOccurance.new(self, AUDIT_QUESTIONS).call
  end
end
