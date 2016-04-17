json.monthly_audits(@monthly_audits) do |audit|
  json.partial! 'loan_audit_info', audit: audit

  json.(audit, :agent_page1_occurance, :address_completed_occurance ,:all_boxes_completed_occurance, :sectionb_page1_completed_occurance ,:tolerance_cure_necessary_occurance ,:seller_concession_appear_occurance, :cash_from_borrower_match_occurance , :agent_page2_occurance ,:correct_fees_800section_credits_occurance ,:correct_fees_900section_occurance ,:agent_charges_match_approved_occurance ,:agent_show_correct_mbfees_occurance ,:agent_changes_page2_hud_fees_occurance ,:agent_page3_occurance ,:gfe_match_final_gfe_occurance ,:hud1_side_match_page2_hud_occurance ,:loan_terms_section_completed_acc_occurance ,:new_costs_cure_for_agent_completion_occurance ,:seller_credit_changed_occurance ,:realtor_credit_changed_occurance ,:lender_credit_changed_occurance ,:fee_increase_occurance ,:fee_decrease_occurance ,:added_apr_fees_occurance ,:changed_closing_docs_occurance ,:changed_legal_docs_occurance ,:changed_power_of_attorney_occurance ,:changed_doc_for_trust_occurance ,:incorrectly_date_docs_occurance ,:changed_closing_dates_occurance ,:agent_executed_documents_correctly_occurance ,:followed_closing_instructions_occurance ,:changed_nortc_correctly_occurance ,:closing_conditions_been_met_occurance ,:agent_sent_proper_doc_fundingauth_occurance ,:agent_disburse_loan_properdate_occurance ,:notification_pending_litigation_occurance ,:pay_off_liens_occurance )

  json.total_hud_per_loan audit.total_hud_occurance   
  json.hud_review audit.hud_review

  json.hud_defect_perc audit.get_percentage(audit.hud_review, audit.total_hud_occurance)
  json.total_defect_perc audit.get_percentage(audit.total_occurance, audit.qcount)

end
