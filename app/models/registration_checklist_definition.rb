class RegistrationChecklistDefinition < ChecklistDefinition

  def build_sections
    secs = []
    secs << registration_checklist_section
    secs
  end

  private

  def registration_checklist_section
    section "Registration Checklist" do |s|

      s.question "recvd_intent_to_proceed", prompt: "Intent to Proceed Received?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: AppliesToAny.new([wholesale, retail, pb, cd ]),
        display_message_on: { value: 'No', message: "File cannot proceed, contact originator" }

      s.question "fha_case_file_id_exists", prompt: "Is there an FHA Case File ID?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: fha

      s.question "case_number_assigned", prompt: "Is case number assignment/request imaged?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: AppliesToAll.new([fha, wholesale]),
        display_message_on: { value: "No", message: "File cannot proceed, contact originator" }

      s.question "ufmip_disclosed", prompt: "UFMIP disclosed?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: fha,
        display_message_on: { value: "No", message: "Contact Change Request to notify of re-disclosure" }

      s.question "certificate_of_eligibility_present", prompt: "Is the Certificate of Eligibility present?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: va

      s.question "certificate_of_eligibility_imaged", prompt: "Certificate of eligibility imaged?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: non_irrl_va,
        display_message_on: { value: "No", message: "File cannot proceed, contact originator" }

      s.question "funding_fee_disclosed", prompt: "Correct funding fee disclosed?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: va,
        display_message_on: { value: "No", message: "Contact Change Request to notify re-disclosure" }

      s.question "options_cert_anti_steering_disclosure_present", prompt: "Is there a loan Options Certification/Anti-Steering Disclosure?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: AppliesToAll.new([wholesale, lpmi])

      s.question "lpmi_imaged", prompt: "Lender Paid Transaction is LOC/Anti-Steering Imaged?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: AppliesToAll.new([wholesale, lpmi])

      s.question "lpmi_img_condition_added", prompt: "Was condition added?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: AppliesToAll.new([wholesale, lpmi]),
        conditional_on: { name: 'lpmi_imaged', equals: 'No'},
        display_message_on: { value: "No", message: "Must add condition" }

      s.question "required_signatures_present", prompt: "On 1003: Are required signatures and date present?",
        input_type: "select", options: [ "Yes", "No" ],
        display_message_on: { value: "No", message: "File cannot proceed, contact originator" }

      s.question "does_loan_originator_match", prompt: "Does Loan Originator on the imaged 1003 Application & MortgageBot match?",
        input_type: "select", options: [ "Yes", "No" ]

      s.question "is_nmls_check_complete", prompt: "Is the NMLS Check Complete?",
        input_type: "select", options: [ "Yes", "No" ],
        display_message_on: { value: 'No', message: "Must be completed"}

      s.question "nmls_condition_added", prompt: "If required, was the condition added?",
        input_type: "select", options: [ "Yes", "NA" ],
        conditional_on: { name: 'is_nmls_check_complete', equals: 'Yes' }

      s.question "did_mb_issue_initial_loan_estimate", prompt: "Did MB issue initial Loan Estimate?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: non_mini_corr

      s.question "is_3551_complete", prompt: "3551 form imaged?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: usda,
        display_message_on: { value: "No", message: "File cannot proceed, contact originator" }

      s.question "gus_completed", prompt: "GUS submission checklist completed and imaged?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: usda,
        display_message_on: { value: "No", message: "File cannot proceed, contact originator"}

      s.question "product_eligible_form_imaged", prompt: "Product eligibility form imaged?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: usda,
        display_message_on: { value: "No", message: "File cannot proceed, contact originator" }

      s.question "gus_find_acceptable", prompt: "Were GUS findings acceptable?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: usda,
        display_message_on: { value: "No", message: "File cannot proceed, contact client services" }

      s.question "is_1003_complete", prompt: "1003 Complete?",
        input_type: "select", options: [ "Yes", "No" ]

      s.question "credit_docs_uploaded", prompt: "Credit Docs Uploaded?",
        input_type: "select", options: [ "Yes", "No" ]

      s.question "aus_match", prompt: "Does AUS match Lock, 1003, and Disclosures?",
        input_type: "select", options: [ "Yes", "No" ]

      s.question "aus_need_update", prompt: "Does AUS need to be updated?",
        input_type: "select", options: [ "Yes", "No" ],
        conditional_on: { name: "aus_match", equals: "No" },
        display_message_on: { value: "No", message: "Contact Change Request to notify of re-disclosure" }

      s.question "uw_submitted", prompt: "Was loan put into UW Submitted status?",
        input_type: "select", options: [ "Yes", "No" ],
        display_message_on: { value: "No", message: "Must be completed" }

      s.question "uw_received", prompt: "Is loan in UW Received state?",
        input_type: "select", options: [ "Yes", "No" ],
        applies_to: AppliesToAny.new([wholesale, mini_corr]),
        conditional_on: { name: "uw_submitted", equals: "Yes" },
        display_message_on: { value: "No", message: "Must be completed" }
    end
  end

end