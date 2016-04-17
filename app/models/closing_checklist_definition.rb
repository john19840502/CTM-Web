class ClosingChecklistDefinition < ChecklistDefinition

  def build_sections
    secs = []
    secs << closing_audit_section
    secs << closing_checklist_section
    secs << mi_section
    secs << credit_report_section
    secs << appraisal_section
    secs << flood_insurance_section
    secs << title_section
    secs << cd_review_section
    secs << compliance_section
    secs << additional_cd_updates
    secs
  end

  private

  def compliance_section
    section "Compliance Review" do |s|

      s.question "high_cost_compliance_checks", prompt: "Does the loan pass all the High Cost Compliance Checks?",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "points_and_fees_calc_reviewed", prompt: "Points and Fees Calculation have been reviewed through Doc Magic and all warnings have been checked for QM?",
        input_type: 'select', options: [ "Yes" ]

      s.question "final_apr_difference_requires_redisclosure", prompt: "Does the difference in final APR require redisclosure?",
        input_type: 'select', options: [ "Yes", "No", "Corrected" ]

      s.question "final_apr", prompt: "What is the Final APR?",
        input_type: 'textbox'

      s.question "warning_page", prompt: "Does the warning page in Doc Magic or Mortgagebot show HPML Warning?",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "warning_page_stop", prompt: "Did you stop to review specific requirements in order to proceed?",
        input_type: 'select', options: [ "Yes", "No" ],
        conditional_on: { name: 'warning_page', equals: 'Yes' }

      s.question "high_priced_mortgage", prompt: "Is the Loan a Higher Priced Mortgage?",
        input_type: 'select', options: [ "Yes", "No" ]
    end
  end

  def cd_review_section
    section "CD Review" do |s|

      s.question "cd_pg_1_info_all_pop_correct", prompt: "Has all the information been populated correctly on the CD Page 1? (Borrower, Seller, Lender, Settlement Agent, etc.)",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "cd_pg_2_all_fees", prompt: "Have you reviewed CD Page 2 to insure all fees are populated including proper lender credits and premium pricing?",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "cd_fees_updated", prompt: "Have the applicable seller paid and paid by other fees been updated to match approval by underwriter, sales contract, and appraisal?",
        input_type: 'select', options: [ "Yes", "No" ],
        display_message_on: { value: 'No', message: "Contact Underwriting for approval and obtain appraisal before closing package can go out."}

      s.question "cd_pg_3_all_info_updated", prompt: "Has all the Borrower and Seller information been updated to reflect all applicable charges and credits on CD Page 3?",
        input_type: 'select', options: [ "Yes", "No" ],
        applies_to: purchase

      s.question "cd_pg_3_cash_amt", prompt: "Does the amount of cash to or from Borrower shown on CD Page 3 meet the underwriting conditions/program guidelines?",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "cd_pg_3_all_payoff", prompt: "Are all payoffs reflected per underwriting condition on CD Page 3?",
        input_type: 'select', options: [ "Yes", "No" ],
        applies_to: refinance

      s.question "cd_same_servicer", prompt: "Is this the same servicer?",
        input_type: 'select', options: [ "Yes", "No" ],
        applies_to: retail

      s.question "cd_updated_payoff", prompt: "Did you get an updated payoff/pay history?",
        input_type: 'select', options: [ "Yes", "No" ],
        conditional_on: { name: 'cd_same_servicer', equals: 'Yes' },
        applies_to: retail

      s.question "cd_pg_5_all_complete", prompt: "On CD Page 5, Have all the calculations and other disclosure box been completed?",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "cd_tolerance_info_provided", prompt: "Did the Closer provide the tolerance cure information to the Team Lead for approval and Note Code to be added to MortgageBot?",
        input_type: 'select', options: [ "Yes", "No" ],
        conditional_on: { name: 'cd_all_tolerance_violate_shown', equals: 'Yes' }

      s.question "cd_ufmip_shown", prompt: "Is the UFMIP refund shown on CD?",
        input_type: 'select', options: [ "Yes", "No", "NA"]

      s.question "cd_sufficient_cash", prompt: "Does the Borrower have sufficient cash to close based on final CD Figures?",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "cd_cash_meet_guidelines", prompt: "Does the cash the borrower is receiving at closing meet guidelines?",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "cd_prepaid_charge_placement", prompt: "Have you followed the proper placement of prepaid finance charges throughout the CD?",
        input_type: 'select', options: [ "Yes", "NA" ]

      s.question "cd_title_charge_in_alpha", prompt: "Are all the title charges shown on the proper lines CD in alpha order?",
        input_type: 'select', options: [ "Yes", "NA" ]

      s.question "cd_grma_shown", prompt: "GA Residental MTG Tax (GRMA) shown on CD?",
        input_type: 'select', options: [ "Yes", "NA" ]

      s.question "cd_fees_reasonable", prompt: "Have you checked that the Doc Prep Fee and notary Fees are they reasonable?",
        input_type: 'select', options: [ "Yes", "NA" ]

      s.question "cd_pbr_amt", prompt: "Amount of Principal Balance Reduction",
        input_type: 'textbox'

      s.question "cd_all_principal_reduction_shown", prompt: "Are all Principal Reductions shown on CD?",
        input_type: 'select', options: [ "Yes", "NA" ]

      s.question "cd_all_escrows_shown", prompt: "Are all Completion Escrows shown on CD?",
        input_type: 'select', options: [ "Yes", "NA" ]

      s.question "cd_fees_unreasonable", prompt: "The Fees are greater than allowable then these fees are deemed unreasonable and need to be added into the points and fees calculation <ul><li>Are these fees greater than $250.00 for Doc Prep</li><li>Are the Fees greater than $300 for Notary Fees</li></ul>",
        input_type: 'select', options: [ "Yes", "NA" ]

      s.question "cd_all_review_against_last_le", prompt: "Did you review all pages of the CD against the last LE that is in MortgageBot Image Flow?",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "cd_sasp_complete", prompt: "Did you review the Settlement Agent on Service Provider for proper completion of the CD to meet TRID Guidelines?",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "cd_disclosure_reviewed", prompt: "Have you reviewed the disclosure confirming the services the Borrower shopped for?",
        input_type: 'select', options: [ "Yes", "No" ]
    end
  end

  def title_section
    section "Title Commitment" do |s|
      s.question "settlement_agent_off_list", prompt: "Settlement Agent - Off List?",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "applied_fees_for_compliance_with_regulation", prompt: "Verify Affiliate Disclosures in the file and if affiliate Company is listed did we apply the fees for compliance with the regulation?",
        input_type: 'select', options: ["Yes", "NA"]

      s.question "proposed_insured_names_and_vesting_match", prompt: "Proposed Insured Names and vesting match",
        input_type: 'select', options: ["Yes", "No"]

      s.question "accurate_mortgage_name_on_preliminary_title", prompt: "Proposed Mortgagee Name accurate on the preliminary title",
        input_type: 'select', options: ["Yes", "No"]

      s.question "endorsements", prompt: "Endorsements",
        input_type: 'textbox25'

      s.question "title_exception", prompt: "Title Exception",
        input_type: 'textbox25'

      s.question "title_commitment_date", prompt: "Title Commitment Date",
        input_type: 'datebox'

      s.question "commitment_number", prompt: "Commitment Number",
        input_type: 'textbox25'

      s.question "have_legal_description", prompt: "Do you have a legal description?",
        input_type: 'select', options: ["Yes", "No"]

      s.question "legal_match_appraisal", prompt: "Does the legal match the appraisal",
        input_type: 'select', options: ["Yes", "No", "N/A"]

      s.question "tax_id", prompt: "Tax ID",
        input_type: 'textbox25'

      s.question "tax_id_match_appraisal", prompt: "Does the Tax ID match the appraisal?",
        input_type: 'select', options: ["Yes", "No"]

      s.question "tax_amounts_listed_preliminary_commitment", prompt: "Are the Tax Amounts listed on the preliminary Commitment or Tax Certification form.",
       input_type: 'select', options: ["Yes", "No"]

      s.question "are_taxes_due", prompt: "Are Taxes Due?",
        input_type: 'select', options: ["Yes", "No"],
        display_message_on: { value: 'Yes', message: "If any of the due dates are prior to the payment date, Collect Taxes Due."}

      s.question "county_tax", prompt: "County Tax",
        input_type: 'money',
        conditional_on: { name: 'are_taxes_due', equals: 'Yes'},
        optional: true

      s.question "county_tax_due_date1", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'county_tax', presence: true}

      s.question "county_tax_due_date2", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'county_tax', presence: true},
        optional: true

      s.question "county_tax_due_date3", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'county_tax', presence: true},
        optional: true

      s.question "county_tax_due_date4", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'county_tax', presence: true},
        optional: true

      s.question "city_tax", prompt: "City Tax",
        input_type: 'money',
        conditional_on: { name: 'are_taxes_due', equals: 'Yes'},
        optional: true

      s.question "city_tax_due_date1", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'city_tax', presence: true}

      s.question "city_tax_due_date2", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'city_tax', presence: true},
        optional: true

      s.question "city_tax_due_date3", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'city_tax', presence: true},
        optional: true

      s.question "city_tax_due_date4", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'city_tax', presence: true},
        optional: true

      s.question "village_tax", prompt: "Village Tax",
        input_type: 'money',
        conditional_on: { name: 'are_taxes_due', equals: 'Yes'},
        optional: true

      s.question "village_tax_due_date1", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'village_tax', presence: true}

      s.question "village_tax_due_date2", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'village_tax', presence: true},
        optional: true

      s.question "village_tax_due_date3", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'village_tax', presence: true},
        optional: true

      s.question "village_tax_due_date4", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'village_tax', presence: true},
        optional: true

      s.question "other_tax", prompt: "Other Tax",
        input_type: 'money',
        conditional_on: { name: 'are_taxes_due', equals: 'Yes'},
        optional: true

      s.question "other_tax_due_date1", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'other_tax', presence: true}

      s.question "other_tax_due_date2", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'other_tax', presence: true},
        optional: true

      s.question "other_tax_due_date3", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'other_tax', presence: true},
        optional: true

      s.question "other_tax_due_date4", prompt: "Due Date",
        input_type: 'datebox',
        conditional_on: { name: 'other_tax', presence: true},
        optional: true

      s.question "outstanding_judgements_on_title", prompt: "Are there outstanding judgments on the title that have not been cleared?",
        input_type: 'select', options: ["Yes", "No"],
        display_message_on: { value: 'Yes', message: "Proof of payment for judgments needs to be obtained"}

      s.question "outstanding_liens_needs_to_address", prompt: "Are there any outstanding liens that need to be addressed?",
        input_type: 'select', options: ["Yes", "No"]

      s.question "lis_pendens", prompt: "Is there a Lis Pendens?",
        input_type: 'select', options: ["Yes", "No"],
        display_message_on: { value: 'Yes', message: "Stop Closing"}

      s.question "checked_pud_condo_information_on_title", prompt: "Have you checked for PUD or Condo information on the Title Commitment?",
        input_type: 'select', options: ["Yes", "No", "N/A"]

      s.question "dower_homestead_community_property_rights_required", prompt: "Is there Dower, Homestead, Community Property Rights required?",
        input_type: 'select', options: ["Yes", "No"]

      s.question "conditions_added_for_closing_instructions_to_title_cpl", prompt: "Have you added conditions to the closing instructions for all corrections to the Title and CPL?",
        input_type: 'select', options: ["Yes", "No"]

      s.question "schedule_b_exception_reviewed", prompt: "Have all Schedule 'B' exceptions been reviewed and approved?",
        input_type: 'select', options: ["Yes", "No"]

    end
  end

  def flood_insurance_section
    section "HOI / HO6 / Flood Insurance" do |s|
      s.question "hoi_company_name", prompt: "Homeowners Insurance Company Name",
        input_type: 'textbox'

      s.question "hoi_company_address", prompt: "Homeowners Insurance Company Street Address",
        input_type: 'textbox'

      s.question "hoi_company_city", prompt: "Homeowners Insurance Company City",
        input_type: 'textbox'

      s.question "hoi_company_state", prompt: "Homeowners Insurance Company State",
        input_type: 'textbox'

      s.question "hoi_company_zip", prompt: "Homeowners Insurance Company Zip",
        input_type: 'zip'

      s.question "hoi_policy_number", prompt: "Hazard Policy Number",
        input_type: 'textbox25'

      s.question "hoi_company_premium", prompt: "Homeowners Insurance Annual Premium Amount",
        input_type: 'money'

      s.question "hoi_due_date", prompt: "Homeowners Insurance Due Date",
        input_type: 'datebox'

      s.question "hoi_policy_amount", prompt: "Homeowners Insurance Coverage/Dwelling Amount",
        input_type: 'money'

      s.question "payment_verification_for_hoi", prompt: "Is there a verification of Payment for HOI/HO6?",
        input_type: 'select', options: ["Yes", "No"]

      s.question "hoi_policy_good", prompt: "Is the homeowners policy good 60 days after closing date?",
        input_type: 'select', options: ["Yes", "No"],
        applies_to: refinance,
        display_message_on: { value: 'No', message: "Policy has to be effective within 60 days of closing date"}

      s.question "flood_insurance", prompt: "Is the loan in flood zone A or V?",
        input_type: 'select', options: ["Yes", "No"],
        applies_to: flood_zone_x

      s.question "flood_insurance_good", prompt: "Has the cert been out to the borrower(s) 10 days prior to closing date?",
        input_type: 'textbox',
        applies_to: flood_zone_x,
        conditional_on: { name: 'flood_insurance', equals: 'Yes'}

      s.question "flood_company_name", prompt: "Flood Cert Company Name",
        input_type: 'textbox',
        applies_to: flood_zone_x,
        conditional_on: { name: 'flood_insurance', equals: 'Yes'}

      s.question "flood_company_address", prompt: "Flood Cert Company Street Address",
        input_type: 'textbox',
        applies_to: flood_zone_x,
        conditional_on: { name: 'flood_insurance', equals: 'Yes'}

      s.question "flood_company_city", prompt: "Flood Cert Company City",
        input_type: 'textbox',
        applies_to: flood_zone_x,
        conditional_on: { name: 'flood_insurance', equals: 'Yes'}

      s.question "flood_company_state", prompt: "Flood Cert Company State",
        input_type: 'textbox',
        applies_to: flood_zone_x,
        conditional_on: { name: 'flood_insurance', equals: 'Yes'}

      s.question "flood_company_zip", prompt: "Flood Cert Company Zip",
        input_type: 'zip',
        applies_to: flood_zone_x,
        conditional_on: { name: 'flood_insurance', equals: 'Yes'}

      s.question "flood_policy_number", prompt: "Flood Policy Number",
        input_type: 'textbox25',
        applies_to: flood_zone_x,
        conditional_on: { name: 'flood_insurance', equals: 'Yes'}

      s.question "flood_company_premium", prompt: "Flood Cert Annual Premium Amount",
        input_type: 'money',
        applies_to: flood_zone_x,
        conditional_on: { name: 'flood_insurance', equals: 'Yes'}

      s.question "flood_due_date", prompt: "Flood Cert Due Date",
        input_type: 'datebox',
        applies_to: flood_zone_x,
        conditional_on: { name: 'flood_insurance', equals: 'Yes'}

      s.question "flood_policy_amount", prompt: "Flood Insurance Coverage/Dwelling Amount",
        input_type: 'money',
        applies_to: flood_zone_x,
        conditional_on: { name: 'flood_insurance', equals: 'Yes'}

      s.question "flood_policy_good", prompt: "Is the flood policy good 60 days after closing date?",
        input_type: 'select', options: ["Yes", "No"],
        applies_to: AppliesToAll.new([refinance, flood_zone_x]),
        display_message_on: { value: 'No', message: "Policy has to be effective within 60 days of closing date"},
        conditional_on: { name: 'flood_insurance', equals: 'Yes'}

      s.question "flood_policy_zone_match", prompt: "Does the Zone on the Flood Policy match the Flood Cert?",
        input_type: 'select', options: ["Yes", "No"],
        applies_to: flood_zone_x,
        conditional_on: { name: 'flood_insurance', equals: 'Yes'}

      s.question "condition_added_for_policy_corrections", prompt: "Did you add closing condition for any and all corrections needed to the policy? - Title Policy Section",
        input_type: 'select', options: ["Yes", "No"],
        applies_to: flood_zone_x,
        conditional_on: { name: 'flood_insurance', equals: 'Yes'}

      s.question "condo_policy_good_for_60_days", prompt: "If the Condo Master Policy is due within the next 60 days, do we have an updated Master Policy Dec Page?",
        input_type: 'select', options: ["Yes", "No", "N/A"],
        applies_to: flood_zone_x,
        display_message_on: { value: 'No', message: "Policy has to be effective within 60 days Of closing date"},
        conditional_on: { name: 'flood_insurance', equals: 'Yes'}

      s.question "condo_60_day_note_codes", prompt: "If expiring before 60 days after, have you added the applicable note codes?",
        input_type: 'select', options: ["Yes", "No"],
        applies_to: flood_zone_x,
        conditional_on: { name: "condo_policy_good_for_60_days", equals: "No" }

      s.question "condo_60_day_underwriting_condition", prompt: "If expiring before 60 days did you add the applicable underwriting condition for the expiring insurance disclosure?",
        input_type: 'select', options: ["Yes", "No"],
        applies_to: flood_zone_x,
        conditional_on: { name: "condo_policy_good_for_60_days", equals: "No" }

    end
  end

  def appraisal_section
    section "Appraisal" do |s|
      s.question "appraisal_company", prompt: "What is the Appraisal Company?",
        input_type: 'textbox25'

      s.question "appraisal_invoice_amt_1", prompt: "What are the Appraisal invoice Amount(s)?",
        input_type: 'money'

      s.question "appraisal_invoice_amt_2", prompt: "What are the Appraisal invoice Amount(s)?",
        input_type: 'money',
        optional: true,
        conditional_on: {name: "appraisal_invoice_amt_1", presence: true }

      s.question "appraisal_invoice_amt_3", prompt: "What are the Appraisal invoice Amount(s)?",
        input_type: 'money',
        optional: true,
        conditional_on: {name: "appraisal_invoice_amt_2", presence: true }

      s.question "appraisal_poc_amt_1", prompt: "What are the Appraisal POC Amount(s)?",
        input_type: 'money'

      s.question "appraisal_poc_amt_2", prompt: "What are the Appraisal POC Amount(s)?",
        input_type: 'money',
        optional: true,
        conditional_on: {name: "appraisal_poc_amt_1", presence: true }

      s.question "appraisal_poc_amt_3", prompt: "What are the Appraisal POC Amount(s)?",
        input_type: 'money',
        optional: true,
        conditional_on: {name: "appraisal_poc_amt_2", presence: true }

      s.question "appraisal_fee_poc_by_borrower", prompt: "Is the Appraisal Fee POC by the borrower?",
        input_type: 'select', options: [ "Yes", "No", "N/A" ]

      s.question "appraisal_invoice_poc_amt_match", prompt: "Does the Appraisal Invoice and the POC amount match?",
        input_type: 'select', options: ["Yes", "No"],
        applies_to: retail

      s.question "appraisal_fee_poc_by_wholesale_lender", prompt: "Is the Appraisal Fee POC by the Wholesale lender?",
        input_type: 'select', options: [ "Yes", "No", "N/A" ],
        applies_to: wholesale

      s.question "multiple_appraisals", prompt: "Are there multi Appraisals?",
        input_type: 'select', options: [ "Yes", "No"]

      s.question "number_of_appraisals_correct", prompt: "Were the correct number of appraisals charged to the borrower?",
        input_type: 'select', options: [ "Yes", "No" ],
        conditional_on: { name: 'multiple_appraisals', equals: 'Yes' }

      s.question "pud_condo_name_listed", prompt: "Is the PUD/Condo Name listed on the appraisal?",
        input_type: 'select', options: [ "Yes", "No", "N/A" ]

      s.question "seller_concession", prompt: "Seller Concession",
        input_type: 'textbox25'

      s.question "mortgage_bot_has_right_type", prompt: "Is the Property type correct in MortgageBot?",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "assists_approved_and_updated", prompt: "Have the Seller/Realtor Assists been approved & system updated by the underwriter?",
        input_type: 'select', options: [ "Yes", "No", "N/A" ]

      s.question "assists_updated_on_appraisal", prompt: "Have the Seller/Realtor Assists been updated on the appraisal?",
        input_type: 'select', options: [ "Yes", "No", "N/A" ]

      s.question "correct_address", prompt: "Is the property address correct?",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "copies_sent_within_proper_time", prompt: "Have all valuation copies of the appraisal been sent to the borrower(s) 3-6 days in advance of the note date?",
        input_type: 'select', options: [ "Yes", "No", "N/A" ]

      s.question "appraisal_to_closing_table", prompt: "Was the appraisal/valuation sent to the closing table?",
        input_type: 'select', options: [ "Yes", "No", "N/A" ],
        conditional_on: { name: 'copies_sent_within_proper_time', equals: 'No' }

      s.question "appraisal_waiver_sent_within_proper_time", prompt: "Is the Optional Waiver for receipt of the appraisal dated 3 days prior to closing?",
        input_type: 'select', options: [ "Yes", "No", "N/A" ],
        conditional_on: { name: 'copies_sent_within_proper_time', equals: 'No' }

      s.question "optional_waiver_image", prompt: "Is appraisal present in image flow to be sent to the closing table if Optional Waiver has been received?",
        input_type: 'select', options: [ "Yes", "No", "N/A" ],
        conditional_on: { name: 'copies_sent_within_proper_time', equals: 'No' }

      s.question "condition_for_appraisal_at_close", prompt: "Is there a condition present for the borrower to be given the appraisal at close?",
        input_type: 'select', options: [ "Yes", "No", "N/A" ],
        conditional_on: { name: 'copies_sent_within_proper_time', equals: 'No' }
    end

  end

  def credit_report_section
    section "Credit Report" do |s|
      s.question "credit_report_company_name", prompt: "What is the Credit Report Company Name?",
        input_type: 'textbox25', applies_to: wholesale

      s.question "credit_report_fee_amount", prompt: "What is the fee amount?",
        input_type: 'money', applies_to: wholesale
  
      s.question "fee_to_match", prompt: "Do we have a fee shown on the credit report and/or an invoice to match what is showing on the LE?",
        input_type: 'select', options: [ "Yes", "No" ],
        display_message_on: { value: 'No', message: "We will charge $0 on the CD to the Borrower"},
        applies_to: wholesale

      s.question "fee_flat_fee", prompt: "Is the credit report fee showing a flat fee?",
        input_type: 'select', options: [ "Yes", "No" ],
        applies_to: retail

      s.question "poc_by_borrower", prompt: "POC by Borrower?",
        input_type: 'select', options: [ "Yes", "No" ],
        applies_to: wholesale

      s.question "by_wholesale_lender", prompt: "By Wholesale Lender?",
        input_type: 'select', options: [ "Yes", "No" ],
        applies_to: wholesale

      s.question "third_party_processing_fee", prompt: "Is there a Third Party Processing Fee?",
        input_type: 'select', options: [ "Yes", "No" ],
        applies_to: wholesale

      s.question "third_party_processing_fee_amt", prompt: "What is the fee amount?",
        input_type: 'money',
        conditional_on: { name: 'third_party_processing_fee', equals: 'Yes' },
        applies_to: wholesale

      s.question "third_party_processing_fee_invoice", prompt: "Do you have an invoice?",
        input_type: 'select', options: [ "Yes", "No" ],
        conditional_on: { name: 'third_party_processing_fee', equals: 'Yes' },
        applies_to: wholesale
      
    end
  end

  def mi_section
    section "Mortgage Insurance" do |s|
      s.question "mortgage_insurance_loan_type", prompt: "Is this Conv, USDA, FHA?",
        input_type: 'select', options: [ "CONV", "USDA", "FHA", "BOND", "VA", "N/A" ]

      s.question "loan_over_80", prompt: "Is the loan FHA/USDA/LTV over 80%?",
        input_type: 'select', options: [ "FHA", "USDA", "OVER 80%" ],
        conditional_on: { name: 'mortgage_insurance_loan_type', one_of: ['FHA','BOND','USDA','CONV'] }

      s.question "mortgage_insurance", prompt: "Is there MI on this Loan?",
        input_type: 'select', options: [ "Yes", "No", "N/A" ],
        conditional_on: { name: 'mortgage_insurance_loan_type', one_of: ['FHA','BOND','USDA','CONV'] }

      s.question "mortgage_insurance_cert_uploaded", prompt: "Is there an MI cert uploaded?",
        input_type: 'select', options: [ "Yes", "No" ],
        conditional_on: { name: 'mortgage_insurance', equals: 'Yes' }

      s.question "loan_amount_on_cert_match_approval", prompt: "Does the loan amount on the cert match the approval?",
        input_type: 'select', options: [ "Yes", "No" ],
        conditional_on: { name: 'mortgage_insurance', equals: 'Yes' }
      
      s.question "mortgage_insurance_cert_correct", prompt: "Is the MI cert correct as Constant/Level renewals?",
        input_type: 'select', options: [ "Yes", "No" ],
        conditional_on: { name: 'mortgage_insurance', equals: 'Yes' }

      s.question "mortgage_insurance_lender_paid", prompt: "Is the MI Lender Paid?",
        input_type: 'select', options: [ "Yes", "No" ],
        conditional_on: { name: 'mortgage_insurance', equals: 'Yes' }

      s.question "loan_locked_as_lender_paid_mortgage_insurance", prompt: "Is the loan locked as Lender Paid MI?",
        input_type: 'select', options: [ "Yes", "No" ],
        conditional_on: { name: 'mortgage_insurance', equals: 'Yes' }

      s.question "have_split_mortgage_insurance_financed", prompt: "Does the loan have Split MI Financed?",
        input_type: 'select', options: [ "Yes", "No" ],
        conditional_on: { name: 'mortgage_insurance', equals: 'Yes' }

      s.question "monthly_payment_match_1003", prompt: "Does the monthly payment match the 1003?",
        input_type: 'select', options: [ "Yes", "No" ],
        conditional_on: { name: 'mortgage_insurance', equals: 'Yes' }

      s.question "mortgage_insurance_factors", prompt: "MI Factors",
        input_type: 'three_percentages',
        conditional_on: { name: 'mortgage_insurance', equals: 'Yes' }

      s.question "mortgage_insurance_financed_fha_usda", prompt: "Is the MIP Financed for FHA/USDA?",
        input_type: 'select', options: [ "Yes", "No" ],
        conditional_on: { name: 'mortgage_insurance', equals: 'Yes' }

      s.question "ufmip_refund", prompt: "Is there an UFMIP Refund?",
        input_type: 'select', options: [ "Yes", "No" ],
        conditional_on: { name: 'mortgage_insurance', equals: 'Yes' }
    end
  end

  def closing_checklist_section
    section "Closing Checklist" do |s|

      s.question "trid_loan", prompt: "Is Applicaton Date prior to 10/03/2015?",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "has_no_lender_admin_fee", prompt: "Is this loan a NO Lender Admin Fee loan?",
        input_type: 'select', options: [ "Yes", "No", "N/A" ],
        display_message_on: { value: 'Yes', message: "Did you confirm removal of the Lender Admin Fee from CD Page 2?"},
        applies_to: wholesale

      s.question "fee_reduction_program_eligible", prompt: "Does the CTMDB reflect this loan is eligible for the Fee Reduction Program?",
        input_type: 'select', options: [ "Yes", "No" ]

      s.question "how_are_fees_paid", prompt: "From the Lock Screen, how are the fees paid?",
        input_type: 'select', options: [ "Lender Paid", "Borrower Paid", "NA"]

      s.question "wholesale_lender_compensation_plan", prompt: "Have you checked the Wholesale Lender Compensation Plan?",
        input_type: 'select', options: ["Yes", "No", "N/A"],
        applies_to: wholesale

      s.question "compare_comp_plans_against_le_lock", prompt: "Did you compare the Comp Plans against the LE and Lock?",
        input_type: 'select', options: ["Yes", "No", "N/A"],
        applies_to: wholesale

      s.question "match_monthly_libor_arm_index", prompt: "Has the Libor/ARM index been updated to match the monthly Libor ARM index?",
        input_type: 'select', options: ["Yes", "No", "N/A"],
        applies_to: arm_loan

      s.question "arm_caps_match_product", prompt: "Do the ARM Caps match the product, Lock and Closing Doc set?",
        input_type: 'select', options: ["Yes", "No", "N/A"],
        applies_to: arm_loan

      s.question "checked_lender_credit", prompt: "Did you check the Lender Credit?",
        input_type: 'select', options: ["Yes", "No"]


      s.question "add_appraisal_c", prompt: "If No, Did you add the appraisal credit?",
        input_type: 'select', options: ["Yes", "No"],
        conditional_on: { name: 'appraisal_invoice_poc_amt_match', equals: 'No' },
        applies_to: retail

    end
  end

  def closing_audit_section
   section "Closing Audit" do |s|

    s.question "was_loan_rushed", prompt: "Was the loan rushed?",
      input_type: 'select', options: [ "Yes", "No" ]

    s.question "was_rush_approved", prompt: "If yes, was the rush approved?",
      input_type: 'select', options: [ "Yes", "No" ],
      conditional_on: { name: 'was_loan_rushed', equals: 'Yes' }

    s.question "rush_reason", prompt: "What was the reason for the rush?",
      input_type: 'loan_rush_reason',
      conditional_on: { name: 'was_loan_rushed', equals: 'Yes' }

    s.question "rush_reason_other", prompt: "Please specify the other reason for the rush.",
      input_type: 'textbox',
      conditional_on: { name: 'rush_reason', equals: 'Other' }

    s.question "escrow_waiver_approved", prompt: "Is the escrow waiver approved?",
      input_type: 'select', options: [ "Yes", "No", "N/A" ]

    s.question "use_power_of_attorney_at_closing", prompt: "Is there Power of Attorney to be used at closing?",
      input_type: 'select', options: [ "Yes", "No" ]

    s.question "has_power_of_attorney_been_approved", prompt: "Has the Power of Attorney been approved?",
      input_type: 'select', options: [ "Yes", "No" ],
      conditional_on: { name: 'use_power_of_attorney_at_closing', equals: 'Yes' }

    s.question "use_trust_at_closing", prompt: "Is there a trust to be used at closing? (One Trust only)",
      input_type: 'select', options: [ "Yes", "No" ]

    s.question "has_trust_been_approved", prompt: "Has the trust been approved by underwriting?",
      input_type: 'select', options: [ "Yes", "No" ],
      conditional_on: { name: 'use_trust_at_closing', equals: 'Yes' }

    s.question "does_loan_have_interest_credit", prompt: "Does the loan have interest credit?",
      input_type: 'select', options: [ "Yes", "No" ]

    s.question "closing_conditions_identified", prompt: "Did you identify what is needed for the closing conditions and have they been added to the closing instructions?",
      input_type: 'select', options: [ "Yes" ]

    s.question "non_applicable_conditions_removed", prompt: "Did you remove any conditions that don't apply to the loan to insure no confusion at time of closing?",
      input_type: 'select', options: [ "Yes" ]
  
    s.question "closing_conditions_for_appraisals_added", prompt: "Did you add closing conditions for appraisals to be given to the Borrower at Closing?",
      input_type: 'select', options: [ "Yes", "N/A" ]

    s.question "is_note_date_prior_to_condition", prompt: "Is Note Date prior to condition stating 'Loan cannot close prior to?'",
      input_type: 'select', options: [ "Yes", "No" ]

    s.question "all_ptc_conditions_cleared", prompt: "Are all CPTC/PTC conditions cleared?",
      input_type: 'select', options: [ "Yes", "No" ]

    s.question "copy_of_lqi_saved_in_imageflow", prompt: "Did you save a copy of the LQI in image flow?",
      input_type: 'select', options: [ "Yes" ]

    s.question "turned_off_lqis", prompt: "Did you turn off all LQI's?",
      input_type: 'select', options: [ "Yes", "No" ]
  end
 end

 def additional_cd_updates
  section "Additional CD Updates/ Information Applicable" do |s|
    s.question "cd_pg_5_all_addresses_show", prompt: "Do all addresses show on the CD Page 5? (Borrower, Seller, Lender, Settlement Agent, etc.)",
      input_type: 'select', options: [ "Yes", "No" ],
      optional: true

    s.question "cd_all_tolerance_violate_shown", prompt: "Are all Tolerance Cure violations shown on the CD?",
      input_type: 'select', options: [ "Yes", "NA"],
      optional: true

    s.question "display_sent_to_borrower", prompt: "Initial CD Sent to Borrower",
      input_type: 'datebox', our_data: { our_attr: "cd_disclosure_date", as: 'date' },
      optional: true

    s.question "display_delivery_method", prompt: "Initial CD Delivery Method",
      input_type: 'select', options: ["E-Delivery","Mail","Hand Carried","Overnight"],
      optional: true

    s.question "display_additional_sent_to_borrower", prompt: "Additional CD Sent to Borrower",
      input_type: 'datebox', our_data: { our_attr: "cd_redisclosure_date", as: 'date' },
      optional: true

    s.question "display_additional_delivery_method", prompt: "Additoinal CD Delivery Method",
      input_type: 'select', options: ["E-Delivery","Mail","Hand Carried","Overnight"],
      optional: true

    s.question "reason_for_additional_cd", prompt: "Reason for additional CD's going out",
      input_type: 'select', options: [ "Change in or incorrect Escrows", "Additional Titleholders being added", "POA or Trusted added after Prelim", "Address Correction", "Pricing Issues", "Floatdown", "Change in Fees", "Change of Loan Program", "Changes in Concessions" ],
      optional: true

    s.question "reason_for_additional_cd_2", prompt: "Reason for additional CD's going out",
      input_type: 'select', options: [ "Change in or incorrect Escrows", "Additional Titleholders being added", "POA or Trusted added after Prelim", "Address Correction", "Pricing Issues", "Floatdown", "Change in Fees", "Change of Loan Program", "Changes in Concessions" ],
      conditional_on: { name: 'reason_for_additional_cd', presence: true },
      optional: true

    s.question "reason_for_additional_cd_3", prompt: "Reason for additional CD's going out",
      input_type: 'select', options: [ "Change in or incorrect Escrows", "Additional Titleholders being added", "POA or Trusted added after Prelim", "Address Correction", "Pricing Issues", "Floatdown", "Change in Fees", "Change of Loan Program", "Changes in Concessions" ],
      conditional_on: { name: 'reason_for_additional_cd_2', presence: true },
      optional: true

    s.question "reason_for_additional_cd_4", prompt: "Reason for additional CD's going out",
      input_type: 'select', options: [ "Change in or incorrect Escrows", "Additional Titleholders being added", "POA or Trusted added after Prelim", "Address Correction", "Pricing Issues", "Floatdown", "Change in Fees", "Change of Loan Program", "Changes in Concessions" ],
      conditional_on: { name: 'reason_for_additional_cd_3', presence: true },
      optional: true

    s.question "date_of_additional_cds", prompt: "Date Additional CD's Sent",
      input_type: 'datebox',
      optional: true

    s.question "date_of_additional_cds_2", prompt: "Date Additional CD's Sent",
      input_type: 'datebox',
      conditional_on: { name: 'date_of_additional_cds', presence: true },
      optional: true

    s.question "date_of_additional_cds_3", prompt: "Date Additional CD's Sent",
      input_type: 'datebox',
      conditional_on: { name: 'date_of_additional_cds_2', presence: true },
      optional: true

    s.question "date_of_additional_cds_4", prompt: "Date Additional CD's Sent",
      input_type: 'datebox',
      conditional_on: { name: 'date_of_additional_cds_3', presence: true },
      optional: true

    s.question "reason_for_not_releasing_docs", prompt: "Why can't Docs be released?",
      input_type: 'select', options: [ "Underwriting Issues", "Short Assets to Close", "Appraisal Issues", "Final Inspection", "Updated Title", "Schedule B Exceptions", "Updated Pay-off demand", "Need to Prove 3.5 Invested in FHA Transaction" ],
      optional: true

    s.question "reason_for_not_releasing_docs_2", prompt: "Why can't Docs be released?",
      input_type: 'select', options: [ "Underwriting Issues", "Short Assets to Close", "Appraisal Issues", "Final Inspection", "Updated Title", "Schedule B Exceptions", "Updated Pay-off demand", "Need to Prove 3.5 Invested in FHA Transaction" ],
      conditional_on: { name: 'reason_for_not_releasing_docs', presence: true },
      optional: true

    s.question "reason_for_not_releasing_docs_3", prompt: "Why can't Docs be released?",
      input_type: 'select', options: [ "Underwriting Issues", "Short Assets to Close", "Appraisal Issues", "Final Inspection", "Updated Title", "Schedule B Exceptions", "Updated Pay-off demand", "Need to Prove 3.5 Invested in FHA Transaction" ],
      conditional_on: { name: 'reason_for_not_releasing_docs_2', presence: true },
      optional: true

    s.question "reason_for_not_releasing_docs_4", prompt: "Why can't Docs be released?",
      input_type: 'select', options: [ "Underwriting Issues", "Short Assets to Close", "Appraisal Issues", "Final Inspection", "Updated Title", "Schedule B Exceptions", "Updated Pay-off demand", "Need to Prove 3.5 Invested in FHA Transaction" ],
      conditional_on: { name: 'reason_for_not_releasing_docs_3', presence: true },
      optional: true

    s.question "date_docs_not_released", prompt: "Date Docs can't be released?",
      input_type: 'datebox',
      optional: true

    s.question "date_docs_not_released_2", prompt: "Date Docs can't be released?",
      input_type: 'datebox',
      conditional_on: { name: 'date_docs_not_released', presence: true },
      optional: true

    s.question "date_docs_not_released_3", prompt: "Date Docs can't be released?",
      input_type: 'datebox',
      conditional_on: { name: 'date_docs_not_released_2', presence: true },
      optional: true

    s.question "date_docs_not_released_4", prompt: "Date Docs can't be released?",
      input_type: 'datebox',
      conditional_on: { name: 'date_docs_not_released_3', presence: true },
      optional: true

    s.question "final_closing_package_sent", prompt: "Date the Final Closing Package was Sent",
      input_type: 'datebox', our_data: { our_attr: "document_out_date", as: 'date' },
      optional: true

    s.question "reason_for_redraws", prompt: "Reasons for Re-draws",
      input_type: 'select', options: [ "Change in Closing Date", "Change in Loan Amount", "Change in Interest Rate", "Change in Sales Price", "Seller and/or Borrower Cancellation", "Vesting", "Changes to the CD" ],
      optional: true

    s.question "reason_for_redraws_2", prompt: "Reasons for Re-draws",
      input_type: 'select', options: [ "Change in Closing Date", "Change in Loan Amount", "Change in Interest Rate", "Change in Sales Price", "Seller and/or Borrower Cancellation", "Vesting", "Changes to the CD" ],
      conditional_on: { name: 'reason_for_redraws', presence: true },
      optional: true

    s.question "reason_for_redraws_3", prompt: "Reasons for Re-draws",
      input_type: 'select', options: [ "Change in Closing Date", "Change in Loan Amount", "Change in Interest Rate", "Change in Sales Price", "Seller and/or Borrower Cancellation", "Vesting", "Changes to the CD" ],
      conditional_on: { name: 'reason_for_redraws_2', presence: true },
      optional: true

    s.question "reason_for_redraws_4", prompt: "Reasons for Re-draws",
      input_type: 'select', options: [ "Change in Closing Date", "Change in Loan Amount", "Change in Interest Rate", "Change in Sales Price", "Seller and/or Borrower Cancellation", "Vesting", "Changes to the CD" ],
      conditional_on: { name: 'reason_for_redraws_3', presence: true },
      optional: true

    s.question "date_of_closing_request_cancellation", prompt: "Date Closing Request was Cancelled?",
      input_type: 'datebox',
      optional: true
        
    s.question "closing_redraw_date", prompt: "Closing Re-draw Date?",
      input_type: 'datebox',
      optional: true
        
    s.question "closing_redraw_date_2", prompt: "Closing Re-draw Date?",
      input_type: 'datebox',
      conditional_on: { name: 'closing_redraw_date', presence: true },
      optional: true
        
    s.question "closing_redraw_date_3", prompt: "Closing Re-draw Date?",
      input_type: 'datebox',
      conditional_on: { name: 'closing_redraw_date_2', presence: true },
      optional: true
        
    s.question "closing_redraw_date_4", prompt: "Closing Re-draw Date?",
      input_type: 'datebox',
      conditional_on: { name: 'closing_redraw_date_3', presence: true },
      optional: true

    s.question "additional_funds_requested_date", prompt: "Additional Funds Requested Date",
      input_type: 'datebox',
      optional: true

    s.question "reason_additional_funds_requested", prompt: "Reason for Additional Funds Requested?",
      input_type: 'select', options: [ "Change in or incorrect Escrows", "Missed and/or incorrect wire", "Principal reductions", "Tolerance cures", "Pricing Exception" ],
      conditional_on: { name: 'additional_funds_requested_date', presence: true },
      optional: true

    s.question "docs_prepared_in_doc_magic_direct", prompt: "Docs Prepared in Doc Magic Direct?",
      input_type: 'select', options: [ "Yes", "No" ],
      optional: true

    s.question "date_docs_prepared_in_doc_magic_direct", prompt: "Date Docs Prepared?",
      input_type: 'datebox',
      conditional_on: { name: 'docs_prepared_in_doc_magic_direct', equals: 'Yes' },
      optional: true

    s.question "reason_docs_prepared_in_doc_magic_direct", prompt: "Reason for docs prepared in Doc Magic Direct?",
      input_type: 'select', options: [ "Changing Trustee for the Deed of Trust", "1 Borrower and 4 people in vesting", "Vesting too long to fit in MB", "Trust with non-borrowing title holders", "Correction to Trust Verbiage", "Mortgagebot down needed to go direct to complete docs", "TRID Contingency", "MortgageBot Down" ],
      conditional_on: { name: 'docs_prepared_in_doc_magic_direct', equals: 'Yes' },
      optional: true

    s.question "funds_requsted", prompt: "Funds Requested?",
      input_type: 'select', options: [ "Yes", "No" ],
      optional: true

    s.question "date_funds_requested_for", prompt: "Date funds requested for",
      input_type: 'datebox',
      optional: true

    s.question "lo_created_cd_for_borrower", prompt: "Did the LO create a CD and provide to the Borrower?",
      input_type: 'select', options: [ "Yes", "No" ],
      optional: true

    s.question "lo_send_cd_to_borrower_without_approval", prompt: "Did the LO send the CD to the Borower without our approval?",
      input_type: 'select', options: [ "Yes", "No" ],
      optional: true

    s.question "lo_make_changes_to_cd_without_approval", prompt: "Did the LO make changes to the CD without our approval?",
      input_type: 'select', options: [ "Yes", "No" ],
      optional: true

    s.question "was_waiver_asked_for", prompt: "Did Borrower or Wholesale Lender ask for a waiver to close earlier than allowable by Regulation?",
      input_type: 'select', options: [ "Yes", "No" ],
      optional: true

    s.question "reason_for_wavier_request", prompt: "Reason for waiver request?",
      input_type: 'textbox',
      optional: true

    s.question "formal_request_to_change_consummation_date", prompt: "Was there a formal request to change the consummation date?",
      input_type: 'select', options: [ "Yes", "No" ],
      optional: true

    s.question "lo_request_lock_edit_after_cd_issuance", prompt: "Did the LO request a lock edit after the intitial CD was issued?",
      input_type: 'select', options: [ "Yes", "No" ],
      optional: true

    s.question "lo_submit_change_request_in_timely_manner", prompt: "Did the LO submit a change request timely after the initial CD was issued?",
      input_type: 'select', options: [ "Yes", "No" ],
      optional: true

    s.question "efn", prompt: "EFN",
      input_type: 'textbox25', 
      applies_to: retail ,
      optional: true

    s.question "amount_of_tolerance_cure", prompt: "Amount of Tolerance Cure",
      input_type: 'money',
      optional: true
  end
 end

end
