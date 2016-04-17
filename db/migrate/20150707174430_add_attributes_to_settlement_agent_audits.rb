class AddAttributesToSettlementAgentAudits < ActiveRecord::Migration
  def up
    add_column :settlement_agent_audits, :address_completed, :string
    add_column :settlement_agent_audits, :address_completed_occurance, :integer, :default => 0
    add_column :settlement_agent_audits, :all_boxes_completed, :string
    add_column :settlement_agent_audits, :all_boxes_completed_occurance, :integer, :default => 0
    add_column :settlement_agent_audits, :sectionb_page1_completed, :string
    add_column :settlement_agent_audits, :sectionb_page1_completed_occurance, :integer, :default => 0
    add_column :settlement_agent_audits, :tolerance_cure_necessary, :string
    add_column :settlement_agent_audits, :tolerance_cure_necessary_occurance, :integer, :default => 0
    add_column :settlement_agent_audits, :seller_concession_appear, :string
    add_column :settlement_agent_audits, :seller_concession_appear_occurance, :integer, :default => 0
    add_column :settlement_agent_audits, :cash_from_borrower_match, :string
    add_column :settlement_agent_audits, :cash_from_borrower_match_occurance, :integer, default: 0

    add_column :settlement_agent_audits, :correct_fees_800section_credits, :string
    add_column :settlement_agent_audits, :correct_fees_800section_credits_occurance, :integer, default: 0
    add_column :settlement_agent_audits, :correct_fees_900section, :string
    add_column :settlement_agent_audits, :correct_fees_900section_occurance, :integer, default: 0
    add_column :settlement_agent_audits, :agent_charges_match_approved, :string
    add_column :settlement_agent_audits, :agent_charges_match_approved_occurance, :integer, default: 0
    add_column :settlement_agent_audits, :agent_show_correct_mbfees, :string
    add_column :settlement_agent_audits, :agent_show_correct_mbfees_occurance, :integer, default: 0
    add_column :settlement_agent_audits, :agent_changes_page2_hud_fees, :string
    add_column :settlement_agent_audits, :agent_changes_page2_hud_fees_occurance, :integer, default: 0
    
    add_column :settlement_agent_audits, :gfe_match_final_gfe, :string
    add_column :settlement_agent_audits, :gfe_match_final_gfe_occurance, :integer, default: 0
    add_column :settlement_agent_audits, :hud1_side_match_page2_hud, :string
    add_column :settlement_agent_audits, :hud1_side_match_page2_hud_occurance, :integer, default: 0
    add_column :settlement_agent_audits, :loan_terms_section_completed_acc, :string
    add_column :settlement_agent_audits, :loan_terms_section_completed_acc_occurance, :integer, default: 0
    add_column :settlement_agent_audits, :new_costs_cure_for_agent_completion, :string
    add_column :settlement_agent_audits, :new_costs_cure_for_agent_completion_occurance, :integer, default: 0

    add_column :settlement_agent_audits, :agent_executed_documents_correctly, :string, default: 'Yes'
    add_column :settlement_agent_audits, :agent_executed_documents_correctly_occurance, :integer, default: 0
    add_column :settlement_agent_audits, :closing_conditions_been_met, :string, default: 'Yes'
    add_column :settlement_agent_audits, :closing_conditions_been_met_occurance, :integer, default: 0
    add_column :settlement_agent_audits, :agent_sent_proper_doc_fundingauth, :string, default: 'Yes'
    add_column :settlement_agent_audits, :agent_sent_proper_doc_fundingauth_occurance, :integer, default: 0
    add_column :settlement_agent_audits, :agent_disburse_loan_properdate, :string, default: 'Yes'
    add_column :settlement_agent_audits, :agent_disburse_loan_properdate_occurance, :integer, default: 0

    change_column_null(:settlement_agent_audits, :agent_executed_documents_correctly, false, 'Yes' )
    change_column_null(:settlement_agent_audits, :closing_conditions_been_met, false, 'Yes' )
    change_column_null(:settlement_agent_audits, :agent_sent_proper_doc_fundingauth, false, 'Yes' )
    change_column_null(:settlement_agent_audits, :agent_disburse_loan_properdate, false, 'Yes' )

    change_column_null(:settlement_agent_audits, :address_completed_occurance, false, 0)
    change_column_null(:settlement_agent_audits, :all_boxes_completed_occurance, false, 0 )
    change_column_null(:settlement_agent_audits, :sectionb_page1_completed_occurance, false, 0)
    change_column_null(:settlement_agent_audits, :tolerance_cure_necessary_occurance, false, 0)
    change_column_null(:settlement_agent_audits, :seller_concession_appear_occurance, false, 0)
    change_column_null(:settlement_agent_audits, :cash_from_borrower_match_occurance, false, 0)

    change_column_null(:settlement_agent_audits, :correct_fees_800section_credits_occurance, false, 0)
    change_column_null(:settlement_agent_audits, :correct_fees_900section_occurance, false, 0)
    change_column_null(:settlement_agent_audits, :agent_charges_match_approved_occurance, false, 0)
    change_column_null(:settlement_agent_audits, :agent_show_correct_mbfees_occurance, false, 0)
    change_column_null(:settlement_agent_audits, :agent_changes_page2_hud_fees_occurance, false, 0)

    change_column_null(:settlement_agent_audits, :gfe_match_final_gfe_occurance, false, 0)
    change_column_null(:settlement_agent_audits, :hud1_side_match_page2_hud_occurance, false, 0)
    change_column_null(:settlement_agent_audits, :loan_terms_section_completed_acc_occurance, false, 0)
    change_column_null(:settlement_agent_audits, :new_costs_cure_for_agent_completion_occurance, false, 0)

    change_column_null(:settlement_agent_audits, :agent_executed_documents_correctly_occurance, false, 0)
    change_column_null(:settlement_agent_audits, :closing_conditions_been_met_occurance, false, 0)
    change_column_null(:settlement_agent_audits, :agent_sent_proper_doc_fundingauth_occurance, false, 0)
    change_column_null(:settlement_agent_audits, :agent_disburse_loan_properdate_occurance, false, 0)
  end

  def down
    remove_column :settlement_agent_audits, :address_completed
    remove_column :settlement_agent_audits, :address_completed_occurance
    remove_column :settlement_agent_audits, :all_boxes_completed
    remove_column :settlement_agent_audits, :all_boxes_completed_occurance
    remove_column :settlement_agent_audits, :sectionb_page1_completed
    remove_column :settlement_agent_audits, :sectionb_page1_completed_occurance
    remove_column :settlement_agent_audits, :tolerance_cure_necessary
    remove_column :settlement_agent_audits, :tolerance_cure_necessary_occurance
    remove_column :settlement_agent_audits, :seller_concession_appear
    remove_column :settlement_agent_audits, :seller_concession_appear_occurance
    remove_column :settlement_agent_audits, :cash_from_borrower_match
    remove_column :settlement_agent_audits, :cash_from_borrower_match_occurance

    remove_column :settlement_agent_audits, :correct_fees_800section_credits
    remove_column :settlement_agent_audits, :correct_fees_800section_credits_occurance
    remove_column :settlement_agent_audits, :correct_fees_900section
    remove_column :settlement_agent_audits, :correct_fees_900section_occurance
    remove_column :settlement_agent_audits, :agent_charges_match_approved
    remove_column :settlement_agent_audits, :agent_charges_match_approved_occurance
    remove_column :settlement_agent_audits, :agent_show_correct_mbfees
    remove_column :settlement_agent_audits, :agent_show_correct_mbfees_occurance
    remove_column :settlement_agent_audits, :agent_changes_page2_hud_fees
    remove_column :settlement_agent_audits, :agent_changes_page2_hud_fees_occurance
    
    remove_column :settlement_agent_audits, :gfe_match_final_gfe
    remove_column :settlement_agent_audits, :gfe_match_final_gfe_occurance
    remove_column :settlement_agent_audits, :hud1_side_match_page2_hud
    remove_column :settlement_agent_audits, :hud1_side_match_page2_hud_occurance
    remove_column :settlement_agent_audits, :loan_terms_section_completed_acc
    remove_column :settlement_agent_audits, :loan_terms_section_completed_acc_occurance
    remove_column :settlement_agent_audits, :new_costs_cure_for_agent_completion
    remove_column :settlement_agent_audits, :new_costs_cure_for_agent_completion_occurance

    remove_column :settlement_agent_audits, :agent_executed_documents_correctly
    remove_column :settlement_agent_audits, :agent_executed_documents_correctly_occurance
    remove_column :settlement_agent_audits, :closing_conditions_been_met
    remove_column :settlement_agent_audits, :closing_conditions_been_met_occurance
    remove_column :settlement_agent_audits, :agent_sent_proper_doc_fundingauth
    remove_column :settlement_agent_audits, :agent_sent_proper_doc_fundingauth_occurance
    remove_column :settlement_agent_audits, :agent_disburse_loan_properdate
    remove_column :settlement_agent_audits, :agent_disburse_loan_properdate_occurance
  end
end
