class SettlementAgentTridAudit < DatabaseRailway
  include AgentAudit

  belongs_to :loan
  belongs_to :escrow_agent
  belongs_to :closing_agent, foreign_key: :settlement_agent
  after_create :calculate_occurance

  # occ_cal represents the Question's each occurance of wrong needs to be counted or not. If it is false only one occurrence of wrong answer is counted.
  # hud: defines if the hud_review is counted for the particular question. If yes each time question is wrong hud review is counted
  
  TRID_AUDIT_QUESTIONS = {
    :cd_page1_correct => {expected: 'Yes', unexpected: 'No', occ_cal: true, hud: true, :checks => {agent_made_corrections_cd_page1: ['Yes']}},
    :cd_page2_correct => {expected: 'Yes', unexpected: 'No', occ_cal: true, hud: true, :checks => {correct_fees_showing_in_loan_cost_section_a: ['Yes'], correct_fees_showing_in_loan_cost_section_b: ['Yes'], correct_fees_showing_in_loan_cost_section_c: ['Yes'], correct_fees_showing_in_loan_cost_section_e: ['Yes'], correct_fees_showing_in_loan_cost_section_f: ['Yes'], correct_fees_showing_in_loan_cost_section_g: ['Yes'], correct_fees_showing_in_loan_cost_section_h: ['Yes'], all_lender_credits_showing_in_section_j: ['Yes', 'NA']}},
    :cd_page3_correct => {expected: 'Yes', unexpected: 'No', occ_cal: true, hud: true, :checks => {cash_close_to_amended: ['No', 'NA'], due_from_borrower_closing_sectionk_amended: ['No', 'NA'], paid_already_borrower_sectionl_amended: ['No', 'NA'], cash_to_close_from_borrower_amdended: ['No', 'NA'], seller_side_affect_borrower_side_of_page3: ['No', 'NA'], payoffs_payments_closing_sectionk_amended: ['No', 'NA']}},
    :cd_page4_correct => {expected: 'Yes', unexpected: 'No', occ_cal: true, hud: true, :checks => {settlement_agent_amend_loan_disclosure_on_page4: ['No']}},
    :cd_page5_correct => {expected: 'Yes', unexpected: 'No', occ_cal: true, hud: true, :checks => {settlement_agent_ament_loan_calculation_disclosure_info: ['No'], applicable_parties_signed_page5: ['Yes']}},
    :cd_page6_correct => {expected: 'Yes', unexpected: 'No', occ_cal: true, hud: true, :checks => {settlement_agent_amend_additional_pages: ['No', 'NA']}},

    :agent_add_apr_fees_after_cd_approval =>            {expected: 'No', occ_cal: false, hud: false, :checks => {}},
    :agent_change_closing_documents_without_approval => {expected: 'No', occ_cal: false, hud: false, :checks => {}},
    :agent_add_individuals_to_legal_docs =>             {expected: 'No', occ_cal: false, hud: false, :checks => {}},
    :agnet_amend_documents_to_use_power_of_attorney =>  {expected: 'No', occ_cal: false, hud: false, :checks => {}},
    :agent_amend_documents_for_trust =>                 {expected: 'No', occ_cal: false, hud: false, :checks => {}},
    :agent_incorrectly_date_documents =>                {expected: 'No', occ_cal: false, hud: false, :checks => {}},
    :agent_change_closing_dates_without_new_docs_approval => {expected: 'No', occ_cal: false, hud: true, :checks => {}},
    :settlement_agent_executed_documents_correctly  =>  {expected: 'Yes', occ_cal: false, hud: false, :checks => {}},
    :agent_followed_our_specific_instructions   =>      {expected: 'Yes', occ_cal: false, hud: false, :checks => {}},
    :agent_changed_nortc_correctly =>                   {expected: 'NA', occ_cal: false, hud: false, :checks => {}},

    :all_closing_conditions_been_met =>                 {expected: 'Yes', occ_cal: false, hud: false, :checks => {}},
    :settlement_agent_send_proper_docs_to_funding_auth_team =>  {expected: 'Yes', occ_cal: false, hud: false, :checks => {}},
    :settlement_agent_disburse_loan_on_proper_date        =>    {expected: 'Yes', occ_cal: false, hud: false, :checks => {}},
    :did_we_receive_settlement_agent_closing_statement    =>    {expected: 'Yes', occ_cal: false, hud: false, :checks => {}},
    :any_difference_between_cd_and_settlement_agent_audit =>    {expected: 'No', occ_cal: false, hud: false, :checks => {}},
    :settlement_agent_fund_loan_prior_to_lock_expiration  =>    {expected: 'Yes', occ_cal: false, hud: false, :checks => {}},
    :did_we_extend_additional_days_on_lock                =>    {expected: 'No', occ_cal: false, hud: false, :checks => {}},
    :have_we_received_notification_of_pending_litigation  =>    {expected: 'No', occ_cal: false, hud: false, :checks => {}},
    :did_agent_pay_off_liens_correctly                    =>    {expected: 'Yes', occ_cal: false, hud: false, :checks => {}}
  }

  def total_hud_occurance
    cd_page1_correct_count + cd_page2_correct_count + cd_page3_correct_count + cd_page4_correct_count + cd_page5_correct_count + cd_page6_correct_count
  end

  def total_occurance
    total_occurance = self.total_hud_occurance + self.other_occurance_count
  end

  def other_occurance_count
    agent_add_apr_fees_after_cd_approval_occurance + agent_change_closing_documents_without_approval_occurance + agent_add_individuals_to_legal_docs_occurance + agnet_amend_documents_to_use_power_of_attorney_occurance + agent_amend_documents_for_trust_occurance + agent_incorrectly_date_documents_occurance + agent_change_closing_dates_without_new_docs_approval_occurance + settlement_agent_executed_documents_correctly_occurance + agent_followed_our_specific_instructions_occurance + agent_changed_nortc_correctly_occurance + all_closing_conditions_been_met_occurance + settlement_agent_send_proper_docs_to_funding_auth_team_occurance + settlement_agent_disburse_loan_on_proper_date_occurance + did_we_receive_settlement_agent_closing_statement_occurance + any_difference_between_cd_and_settlement_agent_audit_occurance + settlement_agent_fund_loan_prior_to_lock_expiration_occurance + did_we_extend_additional_days_on_lock_occurance + have_we_received_notification_of_pending_litigation_occurance + did_agent_pay_off_liens_correctly_occurance
  end

  def calculate_occurance
    SettlementAgentAuditOccurance.new(self, TRID_AUDIT_QUESTIONS).call
  end
end