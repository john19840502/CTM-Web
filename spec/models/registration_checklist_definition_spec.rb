require 'spec_helper'

describe RegistrationChecklistDefinition do

  it "should have only one section" do
    sections = sections_for_loan default_loan
    expect(sections.length).to eq 1
    expect(sections.first.name).to eq "Registration Checklist"
    expect(sections.first.questions.empty?).to be_falsey
  end

  context "recvd_intent_to_proceed" do

    [ Channel.wholesale.identifier, Channel.retail.identifier, Channel.private_banking.identifier, 
      Channel.consumer_direct.identifier].each do |channel|
      it "should apply to #{channel} loans" do
        loan = loan(channel)
        q = question_for_name("recvd_intent_to_proceed", loan)
        expect(q.applicable_to(loan)).to be_truthy
      end
    end

    it "should not apply to reimbursement loans" do
      loan = loan(Channel.reimbursement.identifier)
      q = question_for_name("recvd_intent_to_proceed", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan channel
      loan = default_loan
      allow(loan).to receive(:channel).and_return(channel)
      loan
    end

  end

  context "fha_case_file_id_exists" do

    it "should apply to fha loans" do
      loan = loan(true)
      q = question_for_name("fha_case_file_id_exists", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-fha loans" do
      loan = loan(false)
      q = question_for_name("fha_case_file_id_exists", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_fha
      loan = default_loan
      allow(loan).to receive(:is_fha?).and_return is_fha
      loan
    end

  end

  context "funding_fee_disclosed" do

    it "should apply to va loans" do
      loan = loan(true)
      q = question_for_name("funding_fee_disclosed", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-va loans" do
      loan = loan(false)
      q = question_for_name("funding_fee_disclosed", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_va
      loan = default_loan
      allow(loan).to receive(:is_va?).and_return is_va
      loan
    end

  end

  context "certificate_of_eligibility_present" do

    it "should apply to va loans" do
      loan = loan(true)
      q = question_for_name("certificate_of_eligibility_present", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-va loans" do
      loan = loan(false)
      q = question_for_name("certificate_of_eligibility_present", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_va
      loan = default_loan
      allow(loan).to receive(:is_va?).and_return is_va
      loan
    end

  end

  context "is_3551_complete" do

    it "should apply to usda loans" do
      loan = loan true
      q = question_for_name("is_3551_complete", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-usda loans" do
      loan = loan false
      q = question_for_name("is_3551_complete", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_usda
      loan = default_loan
      allow(loan).to receive(:is_usda?).and_return is_usda
      loan
    end

  end

  context "gus_completed" do

    it "should apply to usda loans" do
      loan = loan true
      q = question_for_name("gus_completed", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-usda loans" do
      loan = loan false
      q = question_for_name("gus_completed", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_usda
      loan = default_loan
      allow(loan).to receive(:is_usda?).and_return is_usda
      loan
    end

  end

  context "product_eligible_form_imaged" do

    it "should apply to usda loans" do
      loan = loan true
      q = question_for_name("product_eligible_form_imaged", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-usda loans" do
      loan = loan false
      q = question_for_name("product_eligible_form_imaged", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_usda
      loan = default_loan
      allow(loan).to receive(:is_usda?).and_return is_usda
      loan
    end

  end

  context "gus_find_acceptable" do

    it "should apply to usda loans" do
      loan = loan true
      q = question_for_name("gus_find_acceptable", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-usda loans" do
      loan = loan false
      q = question_for_name("gus_find_acceptable", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_usda
      loan = default_loan
      allow(loan).to receive(:is_usda?).and_return is_usda
      loan
    end

  end

  context "lpmi_imaged" do 

    it "should apply to locked wholesale lpmi loans" do
      loan = loan Channel.wholesale.identifier, true, true
      q = question_for_name("lpmi_imaged", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should apply to wholesale lpmi loans that are not locked" do
      loan = loan Channel.wholesale.identifier, true, false
      q = question_for_name("lpmi_imaged", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan Channel.retail.identifier, true, false
      q = question_for_name("lpmi_imaged", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    it "should not apply to non-lpmi loans" do
      loan = loan Channel.retail.identifier, false, false
      q = question_for_name("lpmi_imaged", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan channel, is_lender_paid_mi, is_locked
      loan = default_loan
      allow(loan).to receive(:channel).and_return channel
      if is_locked
        allow(loan).to receive(:is_locked?).and_return true
        loan.stub_chain(:lock_loan_datum, :lender_paid_mi) { is_lender_paid_mi }
      elsif is_lender_paid_mi
        loan.stub_chain(:custom_fields, :lender_paid_mi?) { true }
      end
      loan
    end

  end

  context "lpmi_img_condition_added" do

    it "should apply to wholesale lpmi loans" do
      loan = loan Channel.wholesale.identifier, true
      q = question_for_name("lpmi_img_condition_added", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan Channel.retail.identifier, true
      q = question_for_name("lpmi_img_condition_added", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    it "should not apply to non-lpmi loans" do
      loan = loan Channel.wholesale.identifier, false
      q = question_for_name("lpmi_img_condition_added", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan channel, is_lender_paid_mi
      loan = default_loan
      allow(loan).to receive(:channel).and_return channel
      if is_lender_paid_mi
        allow(loan).to receive(:is_locked?).and_return true
      end
      loan.stub_chain(:lock_loan_datum, :lender_paid_mi) { is_lender_paid_mi }
      loan
    end

  end

  context "ufmip_disclosed" do

    it "should apply to fha loans" do
      loan = loan true
      q = question_for_name("ufmip_disclosed", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-fha loans" do
      loan = loan false
      q = question_for_name("ufmip_disclosed", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_fha
      loan = default_loan
      allow(loan).to receive(:is_fha?).and_return(is_fha)
      loan
    end

  end

  context "case_number_assigned" do

    it "should apply to wholesale fha loans" do
      loan = loan(Channel.wholesale.identifier, true)
      q = question_for_name("case_number_assigned", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan(Channel.retail.identifier, true)
      q = question_for_name("case_number_assigned", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    it "should not apply to non-fha loans" do
      loan = loan(Channel.wholesale.identifier, false)
      q = question_for_name("case_number_assigned", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan channel, is_fha
      loan = default_loan
      allow(loan).to receive(:channel).and_return(channel)
      allow(loan).to receive(:is_fha?).and_return(is_fha)
      loan
    end

  end

  context "options_cert_anti_steering_disclosure_present" do

    it "should apply to wholesale lender-paid mi loans" do
      loan = loan(Channel.wholesale.identifier, true)
      q = question_for_name("options_cert_anti_steering_disclosure_present", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan(Channel.retail.identifier, true)
      q = question_for_name("options_cert_anti_steering_disclosure_present", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    it "should not apply to non- lender-paid mi loans" do
      loan = loan(Channel.wholesale.identifier, false)
      q = question_for_name("options_cert_anti_steering_disclosure_present", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan channel, is_lender_paid_mi
      loan = default_loan
      allow(loan).to receive(:channel).and_return(channel)
      if is_lender_paid_mi
        allow(loan).to receive(:is_locked?).and_return true
      end
      loan.stub_chain(:lock_loan_datum, :lender_paid_mi) { is_lender_paid_mi }
      loan
    end

  end

  context "required_signatures_present" do

    it "should be appicable to every loan" do
      loan = default_loan
      q = question_for_name("required_signatures_present", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

  end

  context "does_loan_originator_match" do

    it "should be appicable to every loan" do
      loan = default_loan
      q = question_for_name("does_loan_originator_match", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

  end

  context "is_nmls_check_complete" do

    it "should be appicable to every loan" do
      loan = default_loan
      q = question_for_name("is_nmls_check_complete", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

  end

  context "did_mb_issue_initial_loan_estimate" do

    it "should not apply to mini-corr loans" do
      loan = loan(true)
      q = question_for_name("did_mb_issue_initial_loan_estimate", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    it "should apply to non- mini-corr loans" do
      loan = loan(false)
      q = question_for_name("did_mb_issue_initial_loan_estimate", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    def loan is_mini_corr
      loan = default_loan
      allow(loan).to receive(:mini_corr_loan?).and_return(is_mini_corr)
      loan
    end

  end

  context "uw_received" do

    it "should apply to wholesale loans" do
      loan = loan Channel.wholesale.identifier, false
      q = question_for_name("uw_received", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should apply to mini-corr loans" do
      loan = loan Channel.retail.identifier, true
      q = question_for_name("uw_received", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale non-mini-corr loans" do
      loan = loan Channel.retail.identifier, false
      q = question_for_name("uw_received", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan channel, is_mini_corr
      loan = default_loan
      allow(loan).to receive(:channel).and_return channel
      allow(loan).to receive(:mini_corr_loan?).and_return is_mini_corr
      loan
    end

  end

  context "is_1003_complete" do

    it "should be appicable to every loan" do
      loan = default_loan
      q = question_for_name("is_1003_complete", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

  end

  context "credit_docs_uploaded" do

    it "should be appicable to every loan" do
      loan = default_loan
      q = question_for_name("is_1003_complete", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end
    
  end

  context "certificate_of_eligibility_imaged" do

    it "should apply to VA loans" do
      loan = loan(true, false)
      q = question_for_name("certificate_of_eligibility_imaged", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to VA IRRL loans" do
      loan = loan(true, true)
      q = question_for_name("certificate_of_eligibility_imaged", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    it "should not apply to non-va loans" do
      loan = loan(false, false)
      q = question_for_name("certificate_of_eligibility_imaged", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_va, is_va_irrl
      loan = default_loan
      allow(loan).to receive(:is_va?).and_return(is_va)
      if is_va_irrl
        allow(loan).to receive(:product_code).and_return("VA30IRRL")
      end
      loan
    end

  end

  private

  def default_loan
    loan = double
    allow(loan).to receive(:channel).and_return(Channel.wholesale.identifier)
    allow(loan).to receive(:is_fha?).and_return false
    allow(loan).to receive(:is_va?).and_return false
    allow(loan).to receive(:product_code).and_return "FHA30"
    allow(loan).to receive(:mini_corr_loan?).and_return false
    allow(loan).to receive(:is_usda?).and_return false
    allow(loan).to receive(:is_locked?).and_return false
    loan.stub_chain(:lock_loan_datum, :lender_paid_mi) { false }
    loan.stub_chain(:custom_fields, :lender_paid_mi?) { false }
    loan
  end

  def sections_for_loan loan
    checklist = double
    allow(checklist).to receive(:loan).and_return loan
    sections = RegistrationChecklistDefinition.new(checklist).sections
  end

  def question_for_name name, loan
    questions = sections_for_loan(loan).first.questions
    questions.select{|question| question.name == name }.first
  end

end