class CreateRegistrationChecklists < ActiveRecord::Migration
  def change
    create_table :registration_checklists do |t|
      t.integer :loan_num

      t.string  :fha_case_file_id_exists
      t.string  :certificate_of_eligibility_present
      t.string  :options_cert_anti_steering_disclosure_present
      t.string  :state_specific_disclosure1
      t.string  :state_specific_disclosure2
      t.string  :required_signatures_present
      t.string  :does_loan_originator_match
      t.string  :is_nmls_check_complete
      t.string  :does_property_qualify_for_fee_reduction
      t.string  :did_mb_issue_initial_loan_estimate
      t.string  :were_usda_findings_acceptable
      t.string  :conclusion
      t.string  :warnings
      t.string  :last_updated_by

      t.timestamps
    end
  end
end
