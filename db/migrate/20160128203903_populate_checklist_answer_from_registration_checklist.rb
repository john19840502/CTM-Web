class PopulateChecklistAnswerFromRegistrationChecklist < ActiveRecord::Migration

  def change
    OldRegistrationChecklist.all.each do |record|
        new_cl = RegistrationChecklist.new
        new_cl.loan_num = record.loan_num
        new_cl.created_at = record.created_at
        new_cl.save!

        create_checklist_answer new_cl, "fha_case_file_id_exists", record.fha_case_file_id_exists
        create_checklist_answer new_cl, "certificate_of_eligibility_present", record.certificate_of_eligibility_present
        create_checklist_answer new_cl, "options_cert_anti_steering_disclosure_present", record.options_cert_anti_steering_disclosure_present
        create_checklist_answer new_cl, "state_specific_disclosure1", record.state_specific_disclosure1
        create_checklist_answer new_cl, "state_specific_disclosure2", record.state_specific_disclosure2
        create_checklist_answer new_cl, "required_signatures_present", record.required_signatures_present
        create_checklist_answer new_cl, "does_loan_originator_match", record.does_loan_originator_match
        create_checklist_answer new_cl, "is_nmls_check_complete", record.is_nmls_check_complete
        create_checklist_answer new_cl, "does_property_qualify_for_fee_reduction", record.does_property_qualify_for_fee_reduction
        create_checklist_answer new_cl, "did_mb_issue_initial_loan_estimate", record.did_mb_issue_initial_loan_estimate
        create_checklist_answer new_cl, "were_usda_findings_acceptable", record.were_usda_findings_acceptable
        create_checklist_answer new_cl, "recvd_intent_to_proceed", record.recvd_intent_to_proceed
        create_checklist_answer new_cl, "sspl_uploaded", record.sspl_uploaded
        create_checklist_answer new_cl, "is_1003_complete", record.is_1003_complete
        create_checklist_answer new_cl, "credit_docs_uploaded", record.credit_docs_uploaded
    end
  end

  def create_checklist_answer checklist, name, value
    answers = checklist.checklist_answers
    answer = answers.build
    answer.name = name
    answer.answer = value
    answer.save!
  end

end
