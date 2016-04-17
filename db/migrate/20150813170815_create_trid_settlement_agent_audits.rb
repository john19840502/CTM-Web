class CreateTridSettlementAgentAudits < ActiveRecord::Migration
  def up
    create_table :settlement_agent_trid_audits do |t|
      t.string    :loan_id
      t.string    :settlement_agent
      t.integer   :escrow_agent_id
      t.string    :cd_page1_correct
      t.integer   :cd_page1_correct_count, default: 0
      t.string    :agent_made_corrections_cd_page1
      t.integer   :agent_made_corrections_cd_page1_occurance, default: 0
      t.string    :cd_page2_correct
      t.integer   :cd_page2_correct_count, default: 0
      t.string    :correct_fees_showing_in_loan_cost_section_a
      t.integer   :correct_fees_showing_in_loan_cost_section_a_occurance, default: 0
      t.string    :correct_fees_showing_in_loan_cost_section_b
      t.integer   :correct_fees_showing_in_loan_cost_section_b_occurance, default: 0
      t.string    :correct_fees_showing_in_loan_cost_section_c
      t.integer   :correct_fees_showing_in_loan_cost_section_c_occurance, default: 0
      t.string    :correct_fees_showing_in_loan_cost_section_e
      t.integer   :correct_fees_showing_in_loan_cost_section_e_occurance, default: 0
      t.string    :correct_fees_showing_in_loan_cost_section_f
      t.integer   :correct_fees_showing_in_loan_cost_section_f_occurance, default: 0
      t.string    :correct_fees_showing_in_loan_cost_section_g
      t.integer   :correct_fees_showing_in_loan_cost_section_g_occurance, default: 0
      t.string    :correct_fees_showing_in_loan_cost_section_h
      t.integer   :correct_fees_showing_in_loan_cost_section_h_occurance, default: 0
      t.string    :all_lender_credits_showing_in_section_j
      t.integer   :all_lender_credits_showing_in_section_j_occurance, default:0

      t.string    :cd_page3_correct
      t.integer   :cd_page3_correct_count, default: 0
      t.string    :cash_close_to_amended
      t.integer   :cash_close_to_amended_occurance, default: 0
      t.string    :due_from_borrower_closing_sectionk_amended
      t.integer   :due_from_borrower_closing_sectionk_amended_occurance, default: 0
      t.string    :paid_already_borrower_sectionl_amended
      t.integer   :paid_already_borrower_sectionl_amended_occurance, default: 0
      t.string    :cash_to_close_from_borrower_amdended
      t.integer   :cash_to_close_from_borrower_amdended_occurance, default: 0
      t.string    :seller_side_affect_borrower_side_of_page3
      t.integer   :seller_side_affect_borrower_side_of_page3_occurance, default: 0
      t.string    :payoffs_payments_closing_sectionk_amended
      t.integer   :payoffs_payments_closing_sectionk_amended_occurance, default: 0

      t.string    :cd_page4_correct
      t.integer   :cd_page4_correct_count, default: 0
      t.string    :settlement_agent_amend_loan_disclosure_on_page4
      t.integer   :settlement_agent_amend_loan_disclosure_on_page4_occurance, default: 0

      t.string    :cd_page5_correct
      t.integer   :cd_page5_correct_count, default: 0
      t.string    :settlement_agent_ament_loan_calculation_disclosure_info
      t.integer   :settlement_agent_ament_loan_calculation_disclosure_info_occurance, default: 0
      t.string    :applicable_parties_signed_page5
      t.integer   :applicable_parties_signed_page5_occurance, default: 0

      t.string    :cd_page6_correct
      t.integer   :cd_page6_correct_count, default: 0
      t.string    :settlement_agent_amend_additional_pages
      t.integer   :settlement_agent_amend_additional_pages_occurance, default: 0

      t.string    :agent_add_apr_fees_after_cd_approval, default: 'No'
      t.integer   :agent_add_apr_fees_after_cd_approval_occurance, default: 0
      t.string    :agent_change_closing_documents_without_approval, default: 'No'
      t.integer   :agent_change_closing_documents_without_approval_occurance, default: 0
      t.string    :agent_add_individuals_to_legal_docs, default: 'No'
      t.integer   :agent_add_individuals_to_legal_docs_occurance, default: 0
      t.string    :agnet_amend_documents_to_use_power_of_attorney, default: 'No'
      t.integer   :agnet_amend_documents_to_use_power_of_attorney_occurance, default: 0
      t.string    :agent_amend_documents_for_trust, default: 'No'
      t.string    :agent_amend_documents_for_trust_occurance, default: 0
      t.string    :agent_incorrectly_date_documents, default: 'No'
      t.integer   :agent_incorrectly_date_documents_occurance, default: 0
      t.string    :agent_change_closing_dates_without_new_docs_approval, default: 'No'
      t.integer   :agent_change_closing_dates_without_new_docs_approval_occurance, default: 0
      t.string    :settlement_agent_executed_documents_correctly, default: "Yes"
      t.integer   :settlement_agent_executed_documents_correctly_occurance, default: 0
      t.string    :agent_followed_our_specific_instructions, default: 'Yes'
      t.integer   :agent_followed_our_specific_instructions_occurance, default: 0
      t.string    :agent_changed_nortc_correctly, default: 'NA'
      t.integer   :agent_changed_nortc_correctly_occurance, default: 0

      t.string    :all_closing_conditions_been_met, default: "Yes"
      t.integer   :all_closing_conditions_been_met_occurance, default: 0
      t.string    :settlement_agent_send_proper_docs_to_funding_auth_team, default: "Yes"
      t.integer   :settlement_agent_send_proper_docs_to_funding_auth_team_occurance, default: 0
      t.string    :settlement_agent_disburse_loan_on_proper_date, default: "Yes"
      t.integer   :settlement_agent_disburse_loan_on_proper_date_occurance, default: 0
      t.string    :did_we_receive_settlement_agent_closing_statement, default: 'Yes'
      t.integer   :did_we_receive_settlement_agent_closing_statement_occurance, default: 0
      t.string    :any_difference_between_cd_and_settlement_agent_audit, default: 'No'
      t.integer   :any_difference_between_cd_and_settlement_agent_audit_occurance, default: 0
      t.string    :settlement_agent_fund_loan_prior_to_lock_expiration, default: 'Yes'
      t.integer   :settlement_agent_fund_loan_prior_to_lock_expiration_occurance, default: 0
      t.string    :did_we_extend_additional_days_on_lock
      t.integer   :did_we_extend_additional_days_on_lock_occurance, default: 0
      t.string    :have_we_received_notification_of_pending_litigation, default: 'No'
      t.integer   :have_we_received_notification_of_pending_litigation_occurance, default: 0
      t.string    :did_agent_pay_off_liens_correctly, default: 'Yes'
      t.integer   :did_agent_pay_off_liens_correctly_occurance, default: 0

      t.text      :comments
      t.integer   :hud_review, default: 0
      t.integer   :qcount, default: 0
      t.string    :audited_by
    end
  end

  def down
      drop_table :settlement_agent_trid_audits
  end
end
