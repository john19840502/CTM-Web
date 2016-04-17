FactoryGirl.define do
  factory :settlement_agent_audit do
    address_completed "Yes"
    all_boxes_completed 'Yes' 
    sectionb_page1_completed 'Yes'
    tolerance_cure_necessary 'Yes'
    seller_concession_appear 'Yes'
    cash_from_borrower_match 'Yes'
    correct_fees_800section_credits "Yes"
    correct_fees_900section "Yes"
    agent_charges_match_approved 'Yes'
    agent_show_correct_mbfees 'Yes'
    agent_changes_page2_hud_fees 'No'
    gfe_match_final_gfe 'Yes'
    hud1_side_match_page2_hud 'Yes'
    loan_terms_section_completed_acc 'Yes'
    new_costs_cure_for_agent_completion 'No'
    seller_credit_changed "No"
    realtor_credit_changed "No"
    lender_credit_changed "No"
  end
end