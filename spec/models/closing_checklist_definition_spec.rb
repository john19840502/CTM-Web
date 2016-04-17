require 'spec_helper'

describe ClosingChecklistDefinition do

  it "should have many sections" do
    sections = sections_for_loan default_loan
    expect(sections.length).to eq 10
    verify_section sections[0], "Closing Audit"
    verify_section sections[1], "Closing Checklist"
    verify_section sections[2], "Mortgage Insurance"
    verify_section sections[3], "Credit Report"
    verify_section sections[4], "Appraisal"
    verify_section sections[5], "HOI / HO6 / Flood Insurance"
    verify_section sections[6], "Title Commitment"
    verify_section sections[7], "CD Review"
    verify_section sections[8], "Compliance Review"
    verify_section sections[9], "Additional CD Updates/ Information Applicable"
  end

  context "arm_caps_match_product" do
    it "should apply for arm loans" do
      loan = loan "AdjustableRate"
      q = question_for_name("arm_caps_match_product", "Closing Checklist", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply for non ARM loans" do
      loan = loan "Fixed"
      q = question_for_name("arm_caps_match_product", "Closing Checklist", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan arm_loan
      loan = default_loan
      loan.stub_chain(:mortgage_term, loan_amortization_type: arm_loan)
      loan
    end

  end

  context "cd_pg_3_all_info_updated" do

    it "should apply to purchase loans" do
      loan = loan true
      q = question_for_name("cd_pg_3_all_info_updated", "CD Review", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-purchase loans" do
      loan = loan false
      q = question_for_name("cd_pg_3_all_info_updated", "CD Review", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_purchase
      loan = default_loan
      loan.stub_chain(:loan_general, :is_purchase?) { is_purchase }
      loan
    end

  end

  context "cd_pg_3_all_payoff" do

    it "should apply to refinance loans" do
      loan = loan true
      q = question_for_name("cd_pg_3_all_payoff", "CD Review", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-refinance loans" do
      loan = loan false
      q = question_for_name("cd_pg_3_all_payoff", "CD Review", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_refinance
      loan = default_loan
      loan.stub_chain(:loan_general, :is_refi?) { is_refinance }
      loan
    end

  end

  context "cd_same_servicer" do

    it "should apply to retail loans" do
      loan = loan true
      q = question_for_name("cd_same_servicer", "CD Review", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-retail loans" do
      loan = loan false
      q = question_for_name("cd_same_servicer", "CD Review", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_retail
      loan = default_loan
      if is_retail
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "cd_updated_payoff" do

    it "should apply to retail loans" do
      loan = loan true
      q = question_for_name("cd_updated_payoff", "CD Review", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-retail loans" do
      loan = loan false
      q = question_for_name("cd_updated_payoff", "CD Review", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_retail
      loan = default_loan
      if is_retail
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "hoi_policy_good" do

    it "should apply to refinance loans" do
      loan = loan true
      q = question_for_name("hoi_policy_good", "HOI / HO6 / Flood Insurance", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-refinance loans" do
      loan = loan false
      q = question_for_name("hoi_policy_good", "HOI / HO6 / Flood Insurance", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_refinance
      loan = default_loan
      loan.stub_chain(:loan_general, :is_refi?) { is_refinance }
      loan
    end

  end

  context "flood_policy_good" do

    it "should apply to refinance loans with flood zone A/ V" do
      loan = loan true, "A12"
      q = question_for_name("flood_policy_good", "HOI / HO6 / Flood Insurance", loan)
      expect(q.applicable_to(loan)).to be_truthy

      loan = loan true, "VVV"
      q = question_for_name("flood_policy_good", "HOI / HO6 / Flood Insurance", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-refinance loans" do
      loan = loan false, "A"
      q = question_for_name("flood_policy_good", "HOI / HO6 / Flood Insurance", loan)
      expect(q.applicable_to(loan)).to be_falsey

      loan = loan false, "X"
      q = question_for_name("flood_policy_good", "HOI / HO6 / Flood Insurance", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    it "should not apply to flood zone other than A/ V" do
      loan = loan true, "W"
      q = question_for_name("flood_policy_good", "HOI / HO6 / Flood Insurance", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_refinance, zone
      loan = default_loan
      loan.stub_chain(:loan_general, :is_refi?) { is_refinance }
      loan.stub_chain(:loan_general, :flood_determination, :nfip_flood_zone_identifier) { zone }
      loan
    end

  end

  context "flood zone identifier" do

    [ "flood_insurance", "flood_insurance_good", "flood_company_name", "flood_company_address",
      "flood_company_city", "flood_company_state", "flood_company_zip", "flood_policy_number",
      "flood_company_premium", "flood_due_date", "flood_policy_amount", "flood_policy_zone_match",
      "condition_added_for_policy_corrections", "condo_policy_good_for_60_days",
      "condo_60_day_note_codes", "condo_60_day_underwriting_condition" ].each do |q_name|
      it "should apply to #{q_name} when X" do
        loan = loan("X")
        q = question_for_name(q_name, "HOI / HO6 / Flood Insurance", loan)
        expect(q.applicable_to(loan)).to be_falsey
      end
    end

    [ "flood_insurance", "flood_insurance_good", "flood_company_name", "flood_company_address",
      "flood_company_city", "flood_company_state", "flood_company_zip", "flood_policy_number",
      "flood_company_premium", "flood_due_date", "flood_policy_amount", "flood_policy_zone_match",
      "condition_added_for_policy_corrections", "condo_policy_good_for_60_days",
      "condo_60_day_note_codes", "condo_60_day_underwriting_condition" ].each do |q_name|
      it "should not apply to #{q_name} when non-X" do
        loan = loan("V")
        q = question_for_name(q_name, "HOI / HO6 / Flood Insurance", loan)
        expect(q.applicable_to(loan)).to be_truthy
      end
    end

    [ "flood_insurance", "flood_insurance_good", "flood_company_name", "flood_company_address",
      "flood_company_city", "flood_company_state", "flood_company_zip", "flood_policy_number",
      "flood_company_premium", "flood_due_date", "flood_policy_amount", "flood_policy_zone_match",
      "condition_added_for_policy_corrections", "condo_policy_good_for_60_days",
      "condo_60_day_note_codes", "condo_60_day_underwriting_condition" ].each do |q_name|
      it "should not apply to #{q_name} when non-X" do
        loan = loan("A")
        q = question_for_name(q_name, "HOI / HO6 / Flood Insurance", loan)
        expect(q.applicable_to(loan)).to be_truthy
      end
    end

    [ "flood_insurance", "flood_insurance_good", "flood_company_name", "flood_company_address",
      "flood_company_city", "flood_company_state", "flood_company_zip", "flood_policy_number",
      "flood_company_premium", "flood_due_date", "flood_policy_amount", "flood_policy_zone_match",
      "condition_added_for_policy_corrections", "condo_policy_good_for_60_days",
      "condo_60_day_note_codes", "condo_60_day_underwriting_condition" ].each do |q_name|
      it "should not apply to #{q_name} when nil" do
        loan = loan(nil)
        q = question_for_name(q_name, "HOI / HO6 / Flood Insurance", loan)
        expect(q.applicable_to(loan)).to be_falsey
      end
    end


    def loan zone
      loan = default_loan
      loan.stub_chain(:loan_general, :flood_determination, :nfip_flood_zone_identifier) { zone }
      loan
    end

  end

  context "appraisal_invoice_poc_amt_match" do

    it "should apply to retail loans" do
      loan = loan true
      q = question_for_name("appraisal_invoice_poc_amt_match", "Appraisal", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-retail loans" do
      loan = loan false
      q = question_for_name("appraisal_invoice_poc_amt_match", "Appraisal", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_retail
      loan = default_loan
      if is_retail
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "appraisal_fee_poc_by_wholesale_lender" do

    it "should apply to wholesale loans" do
      loan = loan true
      q = question_for_name("appraisal_fee_poc_by_wholesale_lender", "Appraisal", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan false
      q = question_for_name("appraisal_fee_poc_by_wholesale_lender", "Appraisal", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_wholesale
      loan = default_loan
      if !is_wholesale
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "credit_report_company_name" do

    it "should apply to wholesale loans" do
      loan = loan true
      q = question_for_name("credit_report_company_name", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan false
      q = question_for_name("credit_report_company_name", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_wholesale
      loan = default_loan
      if !is_wholesale
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "credit_report_fee_amount" do

    it "should apply to wholesale loans" do
      loan = loan true
      q = question_for_name("credit_report_fee_amount", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan false
      q = question_for_name("credit_report_fee_amount", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_wholesale
      loan = default_loan
      if !is_wholesale
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "fee_to_match" do

    it "should apply to wholesale loans" do
      loan = loan true
      q = question_for_name("fee_to_match", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan false
      q = question_for_name("fee_to_match", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_wholesale
      loan = default_loan
      if !is_wholesale
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "fee_flat_fee" do

    it "should apply to retail loans" do
      loan = loan true
      q = question_for_name("fee_flat_fee", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-retail loans" do
      loan = loan false
      q = question_for_name("fee_flat_fee", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_retail
      loan = default_loan
      if is_retail
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "poc_by_borrower" do

    it "should apply to wholesale loans" do
      loan = loan true
      q = question_for_name("poc_by_borrower", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan false
      q = question_for_name("poc_by_borrower", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_wholesale
      loan = default_loan
      if !is_wholesale
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "by_wholesale_lender" do

    it "should apply to wholesale loans" do
      loan = loan true
      q = question_for_name("by_wholesale_lender", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan false
      q = question_for_name("by_wholesale_lender", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_wholesale
      loan = default_loan
      if !is_wholesale
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "third_party_processing_fee" do

    it "should apply to wholesale loans" do
      loan = loan true
      q = question_for_name("third_party_processing_fee", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan false
      q = question_for_name("third_party_processing_fee", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_wholesale
      loan = default_loan
      if !is_wholesale
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "third_party_processing_fee_amt" do

    it "should apply to wholesale loans" do
      loan = loan true
      q = question_for_name("third_party_processing_fee_amt", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan false
      q = question_for_name("third_party_processing_fee_amt", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_wholesale
      loan = default_loan
      if !is_wholesale
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "third_party_processing_fee_invoice" do

    it "should apply to wholesale loans" do
      loan = loan true
      q = question_for_name("third_party_processing_fee_invoice", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan false
      q = question_for_name("third_party_processing_fee_invoice", "Credit Report", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_wholesale
      loan = default_loan
      if !is_wholesale
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "has_no_lender_admin_fee" do

    it "should apply to wholesale loans" do
      loan = loan true
      q = question_for_name("has_no_lender_admin_fee", "Closing Checklist", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan false
      q = question_for_name("has_no_lender_admin_fee", "Closing Checklist", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_wholesale
      loan = default_loan
      if !is_wholesale
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "wholesale_lender_compensation_plan" do

    it "should apply to wholesale loans" do
      loan = loan true
      q = question_for_name("wholesale_lender_compensation_plan", "Closing Checklist", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan false
      q = question_for_name("wholesale_lender_compensation_plan", "Closing Checklist", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_wholesale
      loan = default_loan
      if !is_wholesale
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "compare_comp_plans_against_le_lock" do

    it "should apply to wholesale loans" do
      loan = loan true
      q = question_for_name("compare_comp_plans_against_le_lock", "Closing Checklist", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-wholesale loans" do
      loan = loan false
      q = question_for_name("compare_comp_plans_against_le_lock", "Closing Checklist", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_wholesale
      loan = default_loan
      if !is_wholesale
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "add_appraisal_c" do

    it "should apply to retail loans" do
      loan = loan true
      q = question_for_name("add_appraisal_c", "Closing Checklist", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-retail loans" do
      loan = loan false
      q = question_for_name("add_appraisal_c", "Closing Checklist", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_retail
      loan = default_loan
      if is_retail
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  context "efn" do

    it "should apply to retail loans" do
      loan = loan true
      q = question_for_name("efn", "Additional CD Updates/ Information Applicable", loan)
      expect(q.applicable_to(loan)).to be_truthy
    end

    it "should not apply to non-retail loans" do
      loan = loan false
      q = question_for_name("efn", "Additional CD Updates/ Information Applicable", loan)
      expect(q.applicable_to(loan)).to be_falsey
    end

    def loan is_retail
      loan = default_loan
      if is_retail
        allow(loan).to receive(:channel).and_return(Channel.retail.identifier)
      end
      loan
    end

  end

  private

  def verify_section section, name
    expect(section.name).to eq name
    expect(section.questions.empty?).to be_falsey
  end

  def default_loan
    loan = double
    loan.stub_chain(:loan_general, :is_purchase?) { false }
    loan.stub_chain(:loan_general, :is_refi?) { false }
    loan.stub_chain(:loan_general, :flood_determination, :nfip_flood_zone_identifier) { "A" }
    allow(loan).to receive(:channel).and_return(Channel.wholesale.identifier)
    loan
  end

  def question_for_name q_name, s_name, loan
    sections = sections_for_loan(loan)
    section = sections.select{|s| s.name == s_name }.first
    questions = section.questions
    questions.select{|q| q.name == q_name }.first
  end

  def sections_for_loan loan
    checklist = double
    allow(checklist).to receive(:loan).and_return loan
    sections = ClosingChecklistDefinition.new(checklist).sections
  end

end
