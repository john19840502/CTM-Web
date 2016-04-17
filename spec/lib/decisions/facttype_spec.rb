require 'spec_helper'

describe Decisions::Facttype do
  
  example_dti_fact_types = ['DTI', 'ChannelName', 'BaseLoanAmount1003']

  let(:flow_fact_types) { example_dti_fact_types }
  let(:loan) { Loan.new }
  let(:flow_name) {'dti'}
  let(:loan_general) {FactoryGirl.build_stubbed(:loan_general)}
  let(:transmittal_datum) {FactoryGirl.build_stubbed(:transmittal_datum)}

  subject { Decisions::Facttype.new(flow_name, {loan: loan}) }

  before do
    Ctmdecisionator::Flow.stub_chain("explain.fact_types.map").and_return(flow_fact_types)
    allow(loan).to receive(:trid_loan?).and_return(false)
  end

  it "returns only the fact_types associated with the DTI flow" do
    loan.stub(:debt_to_income_ratio) {55}
    loan.stub(:channel) {"Retail"}
    loan.stub_chain(:mortgage_term, :base_loan_amount, :to_s) { 5000.55 }
    flow_fact_types = Decisions::Facttype.new(flow_name, {loan: loan}).execute

    flow_fact_types.keys.should eq(example_dti_fact_types)
    flow_fact_types["DTI"].should eq(55)
    flow_fact_types["ChannelName"].should eq('Retail')
    flow_fact_types["BaseLoanAmount1003"].should eq(5000.55)
  end

  describe "CPM Project ID number" do
    it "should return the CPM Project ID number " do
      loan_general = FactoryGirl.build_stubbed(:loan_general)
      loan.stub(:loan_general) { loan_general }
      loan.stub_chain(:custom_fields) { [build_stubbed(:custom_field, loan_general_id: loan_general.id, attribute_label_description: "CPM Project ID Number", attribute_value: 123456 ), build_stubbed(:custom_field, loan_general_id: loan_general.id, attribute_label_description: "CPM ", attribute_value: 123456 )]}
      project_id = Decisions::Facttype.new(flow_name, {loan: loan}).cpm_project_id_number
      project_id.should eq(123456)
    end

    it "should return the CPM Project ID number " do
      loan_general = FactoryGirl.build_stubbed(:loan_general)
      loan.stub(:loan_general) { loan_general }
      loan.stub_chain(:custom_fields) { [build_stubbed(:custom_field, loan_general_id: loan_general.id, attribute_label_description: "Project ID Number", attribute_value: 123456 )]} 
      project_id = Decisions::Facttype.new(flow_name, {loan: loan}).cpm_project_id_number
      project_id.should be_nil
    end    
  end

  describe "get_attribute_value_for_label_description" do
    let(:label_desc) {"PERS Expiration Date"}
    it "should return attribute values based on the attribute label description sent if it exists" do
      loan_general = FactoryGirl.build_stubbed(:loan_general)
      loan.stub(:loan_general) { loan_general }
      loan.stub_chain(:custom_fields) { [build_stubbed(:custom_field, loan_general_id: loan_general.id, attribute_label_description: "PERS Expiration Date", attribute_value: "1/1/2014" )]} 
      attribute_value = Decisions::Facttype.new(flow_name, {loan: loan}).get_attribute_value_for_label_description(label_desc)
      attribute_value.should eq("1/1/2014")
    end

    it "should return nil if the attribute label description sent does not exist" do
      loan_general = FactoryGirl.build_stubbed(:loan_general)
      loan.stub(:loan_general) { loan_general }
      loan.stub_chain(:custom_fields) { [build_stubbed(:custom_field, loan_general_id: loan_general.id, attribute_label_description: "CPM Project ID Number", attribute_value: "123456" )]} 
      attribute_value = Decisions::Facttype.new(flow_name, {loan: loan}).get_attribute_value_for_label_description(label_desc)
      attribute_value.should be_nil
    end
  end

  describe "PERS List Indicator" do
    it "should return the attributevalue when the label : Is the project on the PERS list?" do
      loan_general = FactoryGirl.build_stubbed(:loan_general)
      loan.stub(:loan_general) { loan_general }
      loan.stub_chain(:custom_fields) { [build_stubbed(:custom_field, loan_general_id: loan_general.id, attribute_label_description: "Is the project on the PERS list?", attribute_value: "10/09/2014" ), build_stubbed(:custom_field, loan_general_id: loan_general.id, attribute_label_description: "CPM ", attribute_value: "123456" )]}
      attribute_value = Decisions::Facttype.new(flow_name, {loan: loan}).pers_list_indicator
      attribute_value.should eq("10/09/2014")
    end
    it "should return nil when the label not matches" do
      loan_general = FactoryGirl.build_stubbed(:loan_general)
      loan.stub(:loan_general) { loan_general }
      loan.stub_chain(:custom_fields) { [build_stubbed(:custom_field, loan_general_id: loan_general.id, attribute_label_description: "CPM Project ID Number", attribute_value: "123456" )]}
      attribute_value = Decisions::Facttype.new(flow_name, {loan: loan}).pers_list_indicator
      attribute_value.should be_nil
    end
  end
  describe "Project Classification" do
    it "should return fnm_project_classification_type if it exists" do
      loan.stub_chain(:loan_feature, fnm_project_classification_type: "TCondominium")
      expect(Decisions::Facttype.new(flow_name, {loan: loan}).project_classification).to eq("T Fannie Mae Review")
    end

    it "should check for other_type fields if the classification id Other" do
      loan.stub(:loan_feature) {build_stubbed(:loan_feature, fnm_project_classification_type: "Other", fnm_project_classification_type_other_description: "Established Project")}
      expect(Decisions::Facttype.new(flow_name, {loan: loan}).project_classification).to eq("Established Project")
    end

    it "should return nil if fnm_project_classification_type , fnm description type and gse proj classification type have blank in it" do
      loan.stub_chain(:loan_feature, fnm_project_classification_type: "")
      loan.stub_chain(:loan_feature, gse_project_classification_type: "")
      expect(Decisions::Facttype.new(flow_name, {loan: loan}).project_classification).to be_nil
    end

    it "should return gse project_classification type when both fnm are blank" do
      loan.stub(:loan_feature) {build_stubbed(:loan_feature, fnm_project_classification_type: "", fnm_project_classification_type_other_description: "", gse_project_classification_type: 'TCondominium')}
      expect(subject.project_classification).to eq('T Fannie Mae Review')
    end
  end

  describe "Upfront Guarantee Fee Percentage" do
    it "should return calculated percentage if value exists" do
      loan.stub_chain(:transaction_detail, mi_and_funding_fee_total_amount: BigDecimal.new("22.00"))
      loan.stub_chain(:mortgage_term, borrower_requested_loan_amount: BigDecimal.new("990.00"))
      expect(Decisions::Facttype.new(flow_name, {loan: loan}).upfront_guarantee_fee_percentage).to eq(2.22)
    end
    it "should return 0 if borrower_requested_loan_amount is not present" do
      loan.stub_chain(:transaction_detail, mi_and_funding_fee_total_amount: BigDecimal.new("22.00"))
      loan.stub_chain(:mortgage_term)
      expect(Decisions::Facttype.new(flow_name, {loan: loan}).upfront_guarantee_fee_percentage).to eq(0)
    end
  end

  describe "Borrower Total Income" do
    it "Should return value if it matches the name and section" do
      allow(loan).to receive(:loan_general).and_return(loan_general)
      loan_general.stub(:calculations) { [build_stubbed(:calculation, loan_general_id: loan_general.id, name: "TotalMonthlyIncome", section: "1008" , value: BigDecimal.new("82.45"))]}
      expect(Decisions::Facttype.new(flow_name, {loan: loan}).borrower_total_income).to eq(82.45)
    end

    it "should return nil if it does not match name and section" do
      loan.stub(:loan_general) { loan_general}
      loan_general.stub(:calculations) { [build_stubbed(:calculation, loan_general_id: loan_general.id, name: "TotalMonthlyPayment", section: "1003" , value: BigDecimal.new("82.45"))]}
      expect(Decisions::Facttype.new(flow_name, {loan: loan}).borrower_total_income).to be_nil
    end
  end

  describe "FHA Endorsement date" do
    it "should return the date if description is FHA Endorsement date" do
      loan_general = FactoryGirl.build_stubbed(:loan_general)
      loan.stub(:loan_general) { loan_general }
      loan.stub_chain(:custom_fields) { [build_stubbed(:custom_field, loan_general_id: loan_general.id, attribute_label_description: "FHA Endorsement Date", attribute_value: "12/10/2014" )]}
      expect(Decisions::Facttype.new(flow_name, {loan: loan}).fha_endorsement_date).to eq("12/10/2014") 
    end
  end

  describe "Mortgage Insurance LTV" do
    let(:mortgage_term) { FactoryGirl.build_stubbed(:mortgage_term, base_loan_amount: 130000) }
    it "should calculate normal LTV when the state is not NY" do
      loan.stub(:loan_general) { loan_general }
      loan_general.stub(loan_type: "Purchase")
      loan_general.stub(:product_code).and_return("FHA15FXD")
      loan_general.stub_chain(:property, state: "MI")
      loan.stub_chain(:lock_loan_datum, property_state: "MI")
      loan_general.stub_chain(:gfe_loan_datum, property_state: "MI")
      loan.stub(:property_appraised_value_amount).and_return(150000)
      loan.stub(:purchase_price_amount).and_return(160000)
      loan.stub(:mortgage_term).and_return(mortgage_term)
      expect(Decisions::Facttype.new(flow_name, {loan: loan}).mortgage_insurance_ltv).to eq(86.667)
    end

    it "should calculate different rules if state is NY" do
      loan.stub(:loan_general) { loan_general }
      loan_general.stub(loan_type: "Purchase")
      loan_general.stub(:product_code).and_return("FHA15FXD")
      loan_general.stub_chain(:property, state: "NY")
      loan.stub_chain(:lock_loan_datum, property_state: "NY")
      loan_general.stub_chain(:gfe_loan_datum, property_state: "MI")
      loan.stub(:property_appraised_value_amount).and_return(160000)
      loan.stub(:purchase_price_amount).and_return(150000)
      loan.stub(:mortgage_term).and_return(mortgage_term)
      expect(Decisions::Facttype.new(flow_name, {loan: loan}).mortgage_insurance_ltv).to eq(81.25)
    end
  end

  describe "Mortgage Insurance Amount 1003" do
    it "should return value when there is a value" do
      loan.stub(:mortgage_insurance_amount_1003).and_return(100)
      expect(subject.mortgage_insurance_amount1003).to eq(100)
    end

    it "should return 0 when there is a 0 value" do
      loan.stub(:mortgage_insurance_amount_1003).and_return(0)
      expect(subject.mortgage_insurance_amount1003).to eq(0)
    end

  end

  describe "Registration Tracking Intent to Proceed Date" do
    it "returns the date string if one is set" do
      loan.stub_chain(:custom_fields, :intent_to_proceed_date_string).and_return ("11/13/2015")
      expect(subject.registration_tracking_intent_to_proceed_date).to eq("11/13/2015")
    end

    it "returns nil if no string set" do
      expect(subject.registration_tracking_intent_to_proceed_date).to eq(nil)
    end
  end

  describe "Borrower Paid Broker Compensation Amount" do
    it "returns the sum of totals of Origination Charges paid to Broker" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({
        fee_category: 'OriginationCharges', paid_to: 'Broker', 
        total_amt: BigDecimal.new("100.10"), paid_by: "Multiple", 
        paid_by_fees: [ 
          OpenStruct.new({paid_by_type: "Lender", pay_amount: "10"}),
          OpenStruct.new({paid_by_type: "Borrower", pay_amount: "23"}),
        ]})
      hud_lines << OpenStruct.new({fee_category: 'OriginationCharges', paid_to: 'Broker', total_amt: BigDecimal.new("100.10"), paid_by: "Lender", paid_by_fees: []})
      hud_lines << OpenStruct.new({fee_category: 'OriginationCharges', paid_to: 'Broker', total_amt: BigDecimal.new("100.10"), paid_by: "Borrower", paid_by_fees: []})
      loan.stub_chain(:hud_lines, :gfe, :with_category_and_paid_to).and_return(hud_lines)

      expect(subject.borrower_paid_broker_compensation_amount).to eq(123.10)
    end

    it "returns 0 when no Origination Charges paid to Broker" do
      expect(subject.borrower_paid_broker_compensation_amount).to eq(0.0)
    end
  end

  describe "LE Premium Pricing Amount" do
    it "returns value stored in Premium Pricing (0.00 for nil)" do
      loan.stub_chain(:hud_lines, :gfe, :by_fee_name, :first).and_return(OpenStruct.new({sys_fee_name: 'Premium Pricing', total_amt: nil}))
      expect(subject.le_premium_pricing_amount).to eq(0.0)
    end

    it "returns value stored in Premium Pricing (0.0)" do
      loan.stub_chain(:hud_lines, :gfe, :by_fee_name, :first).and_return(OpenStruct.new({sys_fee_name: 'Premium Pricing', total_amt: 0.00}))
      expect(subject.le_premium_pricing_amount).to eq(0.0)
    end

    it "returns value stored in the Premium Pricing (100.0)" do
      loan.stub_chain(:hud_lines, :gfe, :by_fee_name, :first).and_return(OpenStruct.new({sys_fee_name: 'Premium Pricing', total_amt: 100.00}))
      expect(subject.le_premium_pricing_amount).to eq(100.0)
    end

    it "returns nil when there is no Premium Pricing GFE line" do
      loan.stub_chain(:hud_lines, :gfe, :by_fee_name, :first).and_return(nil)
      expect(subject.le_premium_pricing_amount).to eq(nil)
    end
  end

  describe "LE Mortgage Insurance Amount" do
    it "returns 0 when total and monthly amount are 0" do
      loan.stub_chain(:hud_lines, :hud_line_value).with('Mortgage Insurance') { 0.0 }
      loan.stub_chain(:hud_lines, :hud_line_value).with('Mortgage Insurance', :monthly_amt) { 0.0 }
      expect(subject.le_mortgage_insurance_amount).to eq(0.0)
    end

    it "returns monthly amount when it is > 0" do
      loan.stub_chain(:hud_lines, :hud_line_value).with('Mortgage Insurance') { 200.0 }
      loan.stub_chain(:hud_lines, :hud_line_value).with('Mortgage Insurance', :monthly_amt) { 100.0 }
      expect(subject.le_mortgage_insurance_amount).to eq(100.0)
    end
  end

  describe "Warranty Deed Fee" do
    it "returns value in total_amount when found" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ sys_fee_name: 'Warranty Deed Prep/Review', total_amt: 225, hud_type: 'GFE' })
      hud_lines << OpenStruct.new({ sys_fee_name: 'Warranty Deed Prep/Review', total_amt: 125, hud_type: 'HUD' })
      hud_lines << OpenStruct.new({ sys_fee_name: 'Discount Points', total_amt: 325, hud_type: 'GFE' })
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.warranty_deed_fee).to eq(225)
    end

    it "returns nil when line not found" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ sys_fee_name: 'Warranty Deed Prep/Review', total_amt: 125, hud_type: 'HUD' })
      hud_lines << OpenStruct.new({ sys_fee_name: 'Discount Points', total_amt: 325, hud_type: 'GFE' })
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.warranty_deed_fee).to eq(nil)
    end
  end

  describe "MI Company Name" do
    [ [1669, "GE"],
      [1670, "PMI"],
      [1671, "RADIAN"],
      [1672, "RMIC"],
      [1673, "MGIC"],
      [1674, "UNITED GUARANTY"],
      [3124, "GENWORTH FINANCIAL"],
      [8352, "ESSENT GUARANTY"],
      [20532, "HUD"],
      [32602, "TRIAD"],
      [9999, nil],
      [nil, nil]
    ].each do |attr_val, expect_val|
      it "should return #{expect_val} when MICompany_1003 is #{attr_val}" do
        loan.stub_chain(:mi_datum, :mi_company_id) { attr_val }
        expect(subject.mi_company_name).to eq(expect_val)
      end
    end
  end

  describe "TBD Property Address" do
    it "should return Yes if any of address contain TBD in it" do
      loan.stub(:loan_general) { loan_general }
      loan.loan_general.property.stub(address: "Sctosdale Circle TBD")
      expect(subject.tbd_property_address_indicator).to eq("Yes")
    end

    it "should return false when TBD not present in address" do
      loan.stub(:loan_general) { loan_general }
      loan.loan_general.lock_loan_datum.stub(property_street_address: "Chicago 3456 TB")
      expect(subject.tbd_property_address_indicator).to eq("No")
    end

    it "should return No if there are no entries for the address" do
      loan.stub(:loan_general) { loan_general }
      expect(subject.tbd_property_address_indicator).to eq("No")
    end
  end

  describe "fact types" do
    context "Borrower National Origin Not Provided (BRW1-BRW4)" do
      let(:government_monitoring) { GovernmentMonitoring.new }

      it "returns 'Yes' when box checked" do
        government_monitoring.race_national_origin_refusal_indicator = true
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_information_not_provided).to eq('Yes')
        expect(subject.borrower2_information_not_provided).to eq('Yes')
        expect(subject.borrower3_information_not_provided).to eq('Yes')
        expect(subject.borrower4_information_not_provided).to eq('Yes')
      end

      it "returns 'No' when box not checked" do
        government_monitoring.race_national_origin_refusal_indicator = false
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_information_not_provided).to eq('No')
        expect(subject.borrower2_information_not_provided).to eq('No')
        expect(subject.borrower3_information_not_provided).to eq('No')
        expect(subject.borrower4_information_not_provided).to eq('No')
      end
    end
    context "Borrower Ethnicity (BRW1-BRW4)" do
      let(:government_monitoring) { GovernmentMonitoring.new }

      it "returns nil when nothing set (no results)" do
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(nil)
        expect(subject.borrower_ethnicity).to eq('')
        expect(subject.borrower2_ethnicity).to eq('')
        expect(subject.borrower3_ethnicity).to eq('')
        expect(subject.borrower4_ethnicity).to eq('')
      end

      it "returns nil when nothing set" do
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_ethnicity).to eq('')
        expect(subject.borrower2_ethnicity).to eq('')
        expect(subject.borrower3_ethnicity).to eq('')
        expect(subject.borrower4_ethnicity).to eq('')
      end

      it "returns blank when value blank" do
        government_monitoring.hmda_ethnicity_type = ''
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_ethnicity).to eq('')
        expect(subject.borrower2_ethnicity).to eq('')
        expect(subject.borrower3_ethnicity).to eq('')
        expect(subject.borrower4_ethnicity).to eq('')
      end

      it "returns Not Hispanic Or Latino if set to NotHisplanicOrLatino" do
        government_monitoring.hmda_ethnicity_type = 'NotHispanicOrLatino'
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_ethnicity).to eq('Not Hispanic Or Latino')
        expect(subject.borrower2_ethnicity).to eq('Not Hispanic Or Latino')
        expect(subject.borrower3_ethnicity).to eq('Not Hispanic Or Latino')
        expect(subject.borrower4_ethnicity).to eq('Not Hispanic Or Latino')
      end

      it "returns Hispanic Or Latino if set to HispanicOrLatino" do
        government_monitoring.hmda_ethnicity_type = 'HispanicOrLatino'
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_ethnicity).to eq('Hispanic Or Latino')
        expect(subject.borrower2_ethnicity).to eq('Hispanic Or Latino')
        expect(subject.borrower3_ethnicity).to eq('Hispanic Or Latino')
        expect(subject.borrower4_ethnicity).to eq('Hispanic Or Latino')
      end

      it "returns Not Applicable if NotApplicable" do
        government_monitoring.hmda_ethnicity_type = 'NotApplicable'
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_ethnicity).to eq('Not Applicable')
        expect(subject.borrower2_ethnicity).to eq('Not Applicable')
        expect(subject.borrower3_ethnicity).to eq('Not Applicable')
        expect(subject.borrower4_ethnicity).to eq('Not Applicable')
      end

      it "returns Information Not Provided if InformationNotProvidedByApplicantInMailInternetOrTelephoneApplication" do
        government_monitoring.hmda_ethnicity_type = 'InformationNotProvidedByApplicantInMailInternetOrTelephoneApplication'
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_ethnicity).to eq('Information Not Provided')
        expect(subject.borrower2_ethnicity).to eq('Information Not Provided')
        expect(subject.borrower3_ethnicity).to eq('Information Not Provided')
        expect(subject.borrower4_ethnicity).to eq('Information Not Provided')
      end

    end

    context "Borrower Not Applicable Race (BRW1-BRW4)" do
      let(:government_monitoring) { GovernmentMonitoring.new }

      it "returns 'Yes' when box not checked" do
        government_monitoring.race_national_origin_refusal_indicator = false
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_not_applicable_race).to eq('Yes')
        expect(subject.borrower2_not_applicable_race).to eq('Yes')
        expect(subject.borrower3_not_applicable_race).to eq('Yes')
        expect(subject.borrower4_not_applicable_race).to eq('Yes')
      end

      it "returns 'No' when box checked" do
        government_monitoring.race_national_origin_refusal_indicator = true
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_not_applicable_race).to eq('No')
        expect(subject.borrower2_not_applicable_race).to eq('No')
        expect(subject.borrower3_not_applicable_race).to eq('No')
        expect(subject.borrower4_not_applicable_race).to eq('No')
      end
    end

    context "Borrower Gender (BRW1-BRW4)" do
      let(:government_monitoring) { GovernmentMonitoring.new }

      it "returns nil when nothing set (no results)" do
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(nil)
        expect(subject.borrower_gender).to eq(nil)
        expect(subject.borrower2_gender).to eq(nil)
        expect(subject.borrower3_gender).to eq(nil)
        expect(subject.borrower4_gender).to eq(nil)
      end

      it "returns nil when nothing set" do
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_gender).to eq(nil)
        expect(subject.borrower2_gender).to eq(nil)
        expect(subject.borrower3_gender).to eq(nil)
        expect(subject.borrower4_gender).to eq(nil)
      end

      it "returns female if set to female" do
        government_monitoring.gender_type = 'Female'
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_gender).to eq('Female')
        expect(subject.borrower2_gender).to eq('Female')
        expect(subject.borrower3_gender).to eq('Female')
        expect(subject.borrower4_gender).to eq('Female')
      end

      it "returns male if set to male" do
        government_monitoring.gender_type = 'Male'
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_gender).to eq('Male')
        expect(subject.borrower2_gender).to eq('Male')
        expect(subject.borrower3_gender).to eq('Male')
        expect(subject.borrower4_gender).to eq('Male')
      end

      it "returns not applicable if not applicable" do
        government_monitoring.gender_type = 'NotApplicable'
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_gender).to eq('Not Applicable')
        expect(subject.borrower2_gender).to eq('Not Applicable')
        expect(subject.borrower3_gender).to eq('Not Applicable')
        expect(subject.borrower4_gender).to eq('Not Applicable')
      end

      it "returns info not provided if info not provided" do
        government_monitoring.gender_type = 'InformationNotProvidedUnknown'
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_gender).to eq('Information Not Provided')
        expect(subject.borrower2_gender).to eq('Information Not Provided')
        expect(subject.borrower3_gender).to eq('Information Not Provided')
        expect(subject.borrower4_gender).to eq('Information Not Provided')
      end
    end

    context "Borrower Race (BRW1-BRW4)" do
      let(:government_monitoring) { GovernmentMonitoring.new }

      it "returns no when there is no value stored (no borrowers)" do
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(nil)
        expect(subject.borrower_race).to eq('No')
        expect(subject.borrower2_race).to eq('No')
        expect(subject.borrower3_race).to eq('No')
        expect(subject.borrower4_race).to eq('No')
      end

      it "returns yes when there is no value stored (borrower found but no race data)" do
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        loan.stub_chain(:loan_general, :hmda_races, :where).and_return([])
        expect(subject.borrower_race).to eq('No')
        expect(subject.borrower2_race).to eq('No')
        expect(subject.borrower3_race).to eq('No')
        expect(subject.borrower4_race).to eq('No')
      end

      it "returns yes when there is a value stored" do
        loan.stub_chain(:loan_general, :hmda_races, :where).and_return([1])
        allow_any_instance_of(Decisions::Facttype).to receive(:get_right_borrower).and_return(government_monitoring)
        expect(subject.borrower_race).to eq('Yes')
        expect(subject.borrower2_race).to eq('Yes')
        expect(subject.borrower3_race).to eq('Yes')
        expect(subject.borrower4_race).to eq('Yes')
      end
    end

    context "Application Taken By" do
      it "returns nil when there is no information" do
        loan.stub_chain(:interviewer).and_return(nil)
        expect(subject.application_taken_by).to eq(nil)
      end

      it "returns human-readable version if one exists" do
        {
          '' => nil,
          'FaceToFace' => 'Face-to-Face',
          'Internet' => 'Internet',
          'Mail' => 'Mail',
          'Telephone' =>'Telephone'
        }.each do |original, answer|
          loan.stub_chain(:interviewer, :application_taken_method_type).and_return(original)
          expect(subject.application_taken_by).to eq(answer)
        end
      end
    end
    context "Number of Borrowers" do
      it "returns nil when there are no borrowers" do
        loan.stub_chain(:borrowers, :count).and_return(0)
        expect(subject.number_of_borrowers).to eq(nil)
      end

      [1,2,3,4].each do |num_borrowers|
        it "returns the number of borrowers" do
          loan.stub_chain(:borrowers, :count).and_return(num_borrowers)
          expect(subject.number_of_borrowers).to eq(num_borrowers)
        end
      end
    end

    context "VOE Completed Date" do
      it "returns nil when there is no loan note for VOE Completed Date" do
        loan.stub_chain(:loan_notes_notes,:voe_completed_dates, :order, :first, :created_date).and_return(nil)
        expect(subject.voe_completed_date).to eq(nil)
      end

      it "returns most recent date when there is a loan note" do
        loan.stub_chain(:loan_notes_notes,:voe_completed_dates, :order, :first, :created_date).and_return(DateTime.new(2015,9,17))
        expect(subject.voe_completed_date).to eq("09/17/2015")
      end
    end
    
    it "returns proper calculated amount (CTMWEB-4848 fix)" do
      loan.stub_chain(:mortgage_term, :base_loan_amount).and_return(159_900)
      expect(subject.calculated_upfront_guarantee_financed_line_g_amount).to eq(4_521.58)
    end

    describe "calculated_upfront_guarantee_financed_line_n_amount" do
      it "should be the line g amount without the cents" do
        subject.stub calculated_upfront_guarantee_financed_line_g_amount: 4521.58
        expect(subject.calculated_upfront_guarantee_financed_line_n_amount).to eq(4_521.00)
      end
    end

    it "returns escrow_waiver_type (value if present)" do
      loan.stub_chain(:additional_loan_datum, :escrow_waiver_type).and_return("Split")
      expect(subject.escrow_waiver_type).to eq("Split")
    end

    it "returns escrow_waiver_type (nil for none)" do
      loan.stub_chain(:additional_loan_datum, :escrow_waiver_type).and_return(nil)
      expect(subject.escrow_waiver_type).to eq(nil)
    end

    it "returns sum of Initial Escrow Payment at Closing (> 0)" do
      loan.stub_chain(:hud_lines,:gfe,:with_category_and_fee_name_start_with).and_return(50.465)
      expect(subject.total_escrow_amount).to eq(50.47)
    end

    it "returns sum of Initial Escrow Payment at Closing (0)" do
      loan.stub_chain(:hud_lines,:gfe,:with_category_and_fee_name_start_with).and_return(0)
      expect(subject.total_escrow_amount).to eq(0)
    end


    it "arm_qualifying_rate should be hte rate percent from arm" do
      loan.stub_chain(:arm, :qualifying_rate_percent).and_return(1.234)
      subject.arm_qualifying_rate.should == 1.234
    end

    it "aus_risk_assessment should be the engine type from transmittal datum" do
      loan.stub_chain(:transmittal_datum, :au_engine_type).and_return("LP")
      subject.aus_risk_assessment.should == "LP"
    end

    it "aus_recommendation should just come from the loan" do
      loan.stub aus_recommendation: 'foo'
      subject.aus_recommendation.should == 'foo'
    end
  end

  describe "ARM Initial Adjustment Period GFE" do
    it "should return value if there is gfe_change_month" do
      loan.stub(:loan_general) { loan_general }
      loan.loan_general.gfe_detail.stub(gfe_change_month: 60)
      expect(subject.arm_initial_adjustment_period_gfe).to eq(60)
    end
    it "should return nil if there is no value" do
      loan.stub(:loan_general) { loan_general }
      loan.loan_general.gfe_detail.stub(gfe_change_month: nil)
      expect(subject.arm_initial_adjustment_period_gfe).to be_nil
    end
  end

  describe "GFE Maximum Interest Rate" do
    it "should return interest rate if there is value " do
      loan.stub(:loan_general) { loan_general }
      loan.loan_general.gfe_detail.stub(gfe_maximum_interest_rate: BigDecimal.new("22.05"))
      expect(subject.gfe_maximum_interest_rate).to eq(22.05)
    end
    it "should return nil if there is no value" do
      loan.stub(:loan_general) { loan_general }
      loan.loan_general.gfe_detail.stub(gfe_maximum_interest_rate: nil)
      expect(subject.gfe_maximum_interest_rate).to be_nil
    end
  end

  describe "Intent To Proceed Date" do
    it "should return value in proper format" do
      loan.stub(:loan_general) { loan_general }
      loan.loan_general.stub(intent_to_proceed_date: DateTime.new(2015, 9, 17))
      expect(subject.intent_to_proceed_date).to eq("09/17/2015")
    end
    it "should return nil if there is no value" do
      loan.stub(:loan_general) { loan_general }
      loan.loan_general.stub(intent_to_proceed_date: nil)
      expect(subject.intent_to_proceed_date).to be_nil
    end
  end

  describe "Can Monthly Amount Rise Indicator" do
    it "should return Yes if the value is true" do
      loan.stub(:loan_general) { loan_general }
      loan.loan_general.gfe_detail.stub(gfe_can_monthly_amount_rise_indicator: true)
      expect(subject.can_monthly_amount_rise_indicator).to eq("Yes")
    end
    it "should return No when value is false" do
      loan.stub(:loan_general) { loan_general }
      loan.loan_general.gfe_detail.stub(gfe_can_monthly_amount_rise_indicator: false)
      expect(subject.can_monthly_amount_rise_indicator).to eq("No")
    end
    it "should return nil when the value is not present" do
      loan.stub(:loan_general) { loan_general }
      loan.loan_general.gfe_detail.stub(gfe_can_monthly_amount_rise_indicator: nil)
      expect(subject.can_monthly_amount_rise_indicator).to be_nil
    end
  end

  describe "Loan Status" do
    it "should return U/W Pending Second Review if status is UW Pending 2nd Review" do
      loan.stub(loan_status: "UW Pending 2nd Review")
      expect(subject.loan_status).to eq("U/W Pending Second Review")
    end
    it "should return U/W Modified w/Conditions if status is UW Modified w/Conditions" do
      loan.stub(loan_status: "UW Modified w/Conditions")
      expect(subject.loan_status).to eq("U/W Modified w/Conditions")
    end
    it "should return loan_staus" do
      loan.stub(loan_status: "File Received")
      expect(subject.loan_status).to eq("File Received")

      loan.stub(loan_status: "U/W Suspended")
      expect(subject.loan_status).to eq("U/W Suspended")
    end
  end

  describe "Amortization Type GFE" do
    it "should return Correct trnslation when there is value" do
      loan.stub(:loan_general) { loan_general}
      loan.loan_general.mortgage_term.stub(loan_amortization_type: "AdjustableRate")
      expect(subject.amortization_type_gfe).to eq("ARM")
    end
    it "should return nil if there is blank" do
      loan.stub(:loan_general) { loan_general}
      loan.loan_general.mortgage_term.stub(loan_amortization_type: "")
      expect(subject.amortization_type_gfe).to be_nil
    end
    it "should return other_amortization_type_description when value is Other" do
      loan.stub(:loan_general) { loan_general}
      loan.loan_general.mortgage_term.stub(loan_amortization_type: "Other", other_amortization_type_description: "Fixed")
      expect(subject.amortization_type_gfe).to eq("Fixed")
    end
  end

  describe "Periodic CAP Lock" do
    it "should return value if there is value for Interval CAP" do
      allow(loan).to receive(:loan_general).and_return(loan_general)
      loan.loan_general.stub_chain(:lock_loan_datum, interval_cap: BigDecimal.new("2.0"))
      expect(subject.periodic_cap_lock).to eq(2.0)
    end
  end

  describe "Lifetime CAP Lock" do
    it "should return value if there is value for Lifetime CAP" do
      allow(loan).to receive(:loan_general).and_return(loan_general)
      loan.loan_general.stub_chain(:lock_loan_datum, lifetime_cap: BigDecimal.new("5.0"))
      expect(subject.lifetime_cap_lock).to eq(5.0)
    end
  end

  describe "First Rate Adjustment CAP Lock" do
    it "should return value if there is value for Initial CAP" do
      loan.stub(:loan_general) { loan_general}
      loan.loan_general.lock_loan_datum.stub(initial_cap: BigDecimal.new("5.0"))
      expect(subject.first_rate_adjustment_cap_lock).to eq(5.0)
    end
  end

  describe "ARM Index Value Lock" do
    it "should return value if IndexCurrentValuePercent has value" do
      loan.stub_chain(:loan_general,:arm,index_current_value_percent: BigDecimal.new("0.794")) 
      expect(subject.arm_index_value_lock).to eq(0.794)
    end 
  end

  describe "ARM Index Value 1003" do
    it "should return value if IndexCurrentValuePercent has value" do
      loan.stub_chain(:loan_general,:arm,index_current_value_percent: BigDecimal.new("0.794")) 
      expect(subject.arm_index_value1003).to eq(0.794)
    end 
  end  

  describe "Periodic CAP 1003" do
    it "should return value if Subsequent Cap Percent has value" do
      loan.stub_chain(:loan_general, :rate_adjustment, :subsequent_cap_percent).and_return(BigDecimal.new("2.0"))
      expect(subject.periodic_cap1003).to eq(2.0)
    end 
    it "should return when there is no value " do
      loan.stub_chain(:loan_general)
      expect(subject.periodic_cap1003).to be_nil
    end
  end 

  describe "First Rate Adjustment CAP 1003" do
    it "should return value if First Rate Adjustment CAP rate has value" do
      loan.stub_chain(:loan_general, :rate_adjustment, :first_change_cap_rate).and_return(BigDecimal.new("5.0"))
      expect(subject.first_rate_adjustment_cap1003).to eq(5.0)
    end 
    it "should return when there is no value " do
      loan.stub_chain(:loan_general)
      expect(subject.first_rate_adjustment_cap1003).to be_nil
    end
  end

  describe "Lifetime CAP 1003" do
    it "should return value if LifetimeCapPercent has value" do
      loan.stub_chain(:loan_general, :rate_adjustment, :lifetime_cap_percent).and_return(BigDecimal.new("5.0"))
      expect(subject.lifetime_cap1003).to eq(5.0)
    end 
    it "should return when there is no value " do
      loan.stub_chain(:loan_general, :rate_adjustment, :lifetime_cap_percent).and_return(nil)
      expect(subject.lifetime_cap1003).to be_nil
    end
  end

  describe "ARM Index Margin 1003" do
    it "should return value if _IndexMarginPercent has value" do
      loan.stub_chain(:loan_general, :arm, :index_margin_percent).and_return(BigDecimal.new("2.25"))
      expect(subject.arm_index_margin1003).to eq(2.25)
    end 
  end

  describe "ARM Index Code" do
    it "should return value if IndexType has value" do
      loan.stub_chain(:loan_general, :arm, :index_type).and_return("OneYearTreasury")
      expect(subject.arm_index_code).to eq("1-Year Treasury")
    end

    it "should return value if IndexType has value" do
      loan.stub_chain(:loan_general, :arm, :index_type).and_return("EleventhDistrictCostOfFunds")
      expect(subject.arm_index_code).to eq("COFI")
    end

    it "should return nil if IndexType has no value" do
      loan.stub_chain(:loan_general, :arm, :index_type).and_return(nil)
      expect(subject.arm_index_code).to be_nil
    end
  end

  describe "ARM Subsequent Adjustment Period 1003" do
    it "should return value if SubsequentRateAdjustmentMonths has value" do
      loan.stub_chain(:loan_general, :rate_adjustment, :subsequent_rate_adjustment_months).and_return(12)
      expect(subject.arm_subsequent_adjustment_period1003).to eq(12)
    end

    it "should return nil if SubsequentRateAdjustmentMonths has no value" do
      loan.stub_chain(:loan_general, :rate_adjustment, :subsequent_rate_adjustment_months).and_return(nil)
      expect(subject.arm_subsequent_adjustment_period1003).to be_nil
    end
  end

  describe "ARM Initial Adjustment Period 1003" do
    it "should return value if FirstRateAdjustmentMonths has value" do
      loan.stub_chain(:loan_general, :rate_adjustment, :first_rate_adjustment_months).and_return(60)
      expect(subject.arm_initial_adjustment_period1003).to eq(60)
    end
    it "should return nil if FirstRateAdjustmentMonths has no value" do
      loan.stub_chain(:loan_general, :rate_adjustment, :first_rate_adjustment_months).and_return(nil)
      expect(subject.arm_initial_adjustment_period1003).to be_nil
    end
  end

  describe "#property_type" do
    context 'should return nil when au engine type is not LP' do
      before {loan.stub_chain(:transmittal_datum, au_engine_type: 'DP')}

      [ ['Attached', 'SFR Attached/Row'],
          ['HighRiseCondominium', 'Condo'],
          ['Detached', 'Single Family Detached'],
          ['PUDAttached', 'PUD Attached'],
          ['Cooperative', 'Co-Operative']
      ].each do |gse_property, expected|
        it "should be #{expected} when gse property type is #{gse_property} and planned_unit_development_indicator is false" do
            loan.stub_chain(:property, planned_unit_development_indicator: false)
            loan.stub(:gse_property_type).and_return(gse_property)
            subject.property_type.should == expected
        end
      end
    end

    context 'when au engine type is LP' do
      before {loan.stub_chain(:transmittal_datum, au_engine_type: 'LP')}
      
      [ ['Attached', 'PUD Attached'],
          ['Condominium', 'Condominium'],
          ['SiteCondo', 'Site Condo'],
          ['Detached', 'PUD Detached'],
          ['ManufacturedHousingSingle', 'Manufactured House Singlewide'],
          ['ManufacturedHomeMultiwide', 'Manufactured House Multiwide'],
          ['Gibberish', 'Gibberish']
      ].each do |gse_property, expected|
        it "should be #{expected} when gse property type is #{gse_property} and planned_unit_development_indicator is true" do
            loan.stub_chain(:property, planned_unit_development_indicator: true)
            loan.stub(:gse_property_type).and_return(gse_property)
            subject.property_type.should == expected
        end
      end
    end
  end

  describe " FHA Total gift amount" do
    it "should return amount when matches Mortgage type and Down payment type" do
      loan.stub_chain(:mortgage_term, mortgage_type: "FHA")
      loan.stub(:down_payments) {[build_stubbed(:down_payment, downpayment_type: "FHAGiftSourceRelative", amount: BigDecimal.new("1000.0")), build_stubbed(:down_payment, downpayment_type: "FHAGiftSourceRelative", amount: BigDecimal.new("3000.0")), build_stubbed(:down_payment, downpayment_type: "SavingAccount", amount: BigDecimal.new("1000.0"))]}
      expect(subject.fha_total_gift_amount).to eq(4000.0)
    end

    it "should return amount when any of the objects match Mortgage type and Down payment type" do
      loan.stub_chain(:mortgage_term, mortgage_type: "VA")
      loan.stub(:down_payments) {[build_stubbed(:down_payment, downpayment_type: "SavingsAccount", amount: BigDecimal.new("1000.0")), build_stubbed(:down_payment, downpayment_type: "FHAGiftSourceRelative", amount: BigDecimal.new("3000.0")), build_stubbed(:down_payment, downpayment_type: "SavingAccount", amount: BigDecimal.new("1000.0"))]}
      expect(subject.fha_total_gift_amount).to eq(3000.0)
    end

    it "should return nil if Mortgage type does not match" do
      loan.stub_chain(:mortgage_term, mortgage_type: "FarmersHomeAdministration")
      loan.stub(:down_payments) {[build_stubbed(:down_payment, downpayment_type: "SavingAccount", amount: BigDecimal.new("1000.0"))]}
      expect(subject.fha_total_gift_amount).to eq(0)
    end
  end

  describe "Flood Insurance Indicator" do
    it "should return yes if indicator is true" do
      loan.stub_chain(:flood_determination, special_flood_hazard_area_indicator: true)
      expect(subject.flood_insurance_indicator).to eq('Yes')
    end

    it 'should return No if indicator is false' do
      loan.stub_chain(:flood_determination, special_flood_hazard_area_indicator: false)
      expect(subject.flood_insurance_indicator).to eq('No')
    end

    it 'should return nil when there is no entry' do
      expect(subject.flood_insurance_indicator).to be_nil
    end
  end

  describe "Flood Insurance expiration date" do
    it "should return the date when there is entry" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with({form_unique_name: "Expirations Dates", attribute_unique_name: 'FloodExpDate'}).and_return([double("CustomField", attribute_value: '12/31/2009')])
      allow(loan).to receive(:custom_fields).and_return(custom_field)
      expect(subject.flood_insurance_expiration_date).to eq("12/31/2009")
    end

    it "should return nil if there are no custom fields" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with({form_unique_name: "Expirations Dates", attribute_unique_name: 'FloodExpDate'}).and_return([double("CustomField")])
      expect(subject.flood_insurance_expiration_date).to be_nil
    end
  end

  describe "Flood Insurance Effective Date" do
    it "should return the date when there is entry" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with({form_unique_name: "Expirations Dates", attribute_unique_name: 'FloodEffectiveDate'}).and_return([double("CustomField", attribute_value: '12/1/2015')])
      allow(loan).to receive(:custom_fields).and_return(custom_field)
      expect(subject.flood_insurance_effective_date).to eq("12/1/2015")
    end

    it "should return nil if there are no custom fields" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with({form_unique_name: "Expirations Dates", attribute_unique_name: 'FloodEffectiveDate'}).and_return([double("CustomField")])
      expect(subject.flood_insurance_effective_date).to be_nil
    end
  end

  describe "Homeowners Insurance Effective Date" do
    it "should return the date when there is entry" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with({form_unique_name: "Expirations Dates", attribute_unique_name: 'HOInsEffectiveDate'}).and_return([double("CustomField", attribute_value: '1/1/2015')])
      allow(loan).to receive(:custom_fields).and_return(custom_field)
      expect(subject.homeowners_insurance_effective_date).to eq("01/01/2015")
    end

    it "should return nil if there are no custom fields" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with({form_unique_name: "Expirations Dates", attribute_unique_name: 'HOInsEffectiveDate'}).and_return([double("CustomField")])
      expect(subject.homeowners_insurance_effective_date).to be_nil
    end
  end

  describe "Homeowners Insurance Expiration Date" do
    it "should return the date when there is entry" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with({form_unique_name: "Expirations Dates", attribute_unique_name: 'HOInsExpDate'}).and_return([double("CustomField", attribute_value: '8/20/2015')])
      allow(loan).to receive(:custom_fields).and_return(custom_field)
      expect(subject.homeowners_insurance_expiration_date).to eq("08/20/2015")
    end

    it "should return nil if there are no custom fields" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with({form_unique_name: "Expirations Dates", attribute_unique_name: 'HOInsExpDate'}).and_return([double("CustomField")])
      expect(subject.homeowners_insurance_expiration_date).to be_nil
    end
  end
  
  describe "Homeowners Insurance Condo Master Policy Expiration Date" do
    it "should return the date when there is entry" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with({form_unique_name: "Expirations Dates", attribute_unique_name: 'CondoMPExpDate'}).and_return([double("CustomField", attribute_value: '2/28/2015')])
      allow(loan).to receive(:custom_fields).and_return(custom_field)
      expect(subject.homeowners_insurance_condo_master_policy_expiration_date).to eq("02/28/2015")
    end

    it "should return nil if there are no custom fields" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with({form_unique_name: "Expirations Dates", attribute_unique_name: 'CondoMPExpDate'}).and_return([double("CustomField")])
      expect(subject.homeowners_insurance_condo_master_policy_expiration_date).to be_nil
    end
  end
 
  describe "Closing Verifications Expiration Date" do
    it "should return the date when there is entry" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with({form_unique_name: "Expirations Dates", attribute_unique_name: 'ClosingVerExpDate'}).and_return([double("CustomField", attribute_value: '3/1/2015')])
      allow(loan).to receive(:custom_fields).and_return(custom_field)
      expect(subject.closing_verifications_expiration_date).to eq("03/01/2015")
    end

    it "should return nil if there are no custom fields" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with({form_unique_name: "Expirations Dates", attribute_unique_name: 'ClosingVerExpDate'}).and_return([double("CustomField")])
      expect(subject.closing_verifications_expiration_date).to be_nil
    end
  end

  describe 'Project Classification Field 1003' do
    [ ['V Condo', 'V Condo'],
      ['G, not in a project or development', nil],
      ['E_PUD', 'E PUD'],
      ['F_PUD', 'F PUD'],
      ['T PUD', 'T PUD'],
      ['T CO-OP', 'T Co-Op'],
      ['OneCooperative', '1 Co-Op'],
      ['TwoCooperative', '2 Co-Op']
    ].each do |gse_prj_classification, expected|
      it "should be #{expected} when gse property type is #{gse_prj_classification} and planned_unit_development_indicator is false" do
        loan.stub_chain(:loan_feature, :gse_project_classification_type).and_return(gse_prj_classification)
        subject.project_classification_field1003.should == expected
      end
    end

    it 'should return nil when there is no matching property type' do
      loan.stub_chain(:loan_feature, :gse_project_classification_type).and_return("")
      expect(subject.project_classification_field1003).to be_nil
    end
  end
  
  describe "Project Classification Field 1008" do
    it 'should return value when fnm project classification type has value' do
      loan.stub_chain(:loan_feature, fnm_project_classification_type: 'Streamlined Review')
      expect(subject.project_classification_field1008).to eq('Streamlined Review')

      loan.stub_chain(:loan_feature, fnm_project_classification_type: 'PCondominium')
      expect(subject.project_classification_field1008).to eq('P Limited Review New')
    end

    it 'should return nil if the Project classification type has FHA' do
      loan.stub_chain(:loan_feature, fnm_project_classification_type: 'U FHA-Approved')
      expect(subject.project_classification_field1008).to be_nil

      loan.stub_chain(:loan_feature, fnm_project_classification_type: 'UCondominium')
      expect(subject.project_classification_field1008).to be_nil
    end

    it 'should check for the fnm project classification type other description when classification type is other' do
      loan.stub_chain(:loan_feature) {build_stubbed(:loan_feature, fnm_project_classification_type: 'Other', fnm_project_classification_type_other_description: '2- to 4-unit Project')}
      expect(subject.project_classification_field1008).to eq('2 to 4 unit Project')
    end

    it 'should return nil when the there is no value' do
      loan.stub_chain(:loan_feature, fnm_project_classification_type: '')
      expect(subject.project_classification_field1008).to be_nil
    end
  end

  describe ".trid_application_received_date" do
    before { loan.stub trid_loan?: true }
    it "should return application date if available" do
      loan.stub trid_application_date: Date.new(2015,6,7)
      expect(subject.trid_application_received_date).to eq("06/07/2015")
    end

    it "should return nil when no application date available" do
      loan.stub trid_application_date: nil
      expect(subject.trid_application_received_date).to be_nil
    end
  end

  describe "Redisclosure Date" do
    loan_general = FactoryGirl.build_stubbed(:loan_general)
    it "should return event date on matching the description" do
      loan_event = double("LoanEvent")
      allow(loan_event).to receive(:where).with({ event_description: 'DocMagic Redisclosure Package Request'}).and_return([double("LoanEvent", event_date: Date.new(2015,3,1))])
      allow(loan).to receive(:loan_general).and_return(loan_general)
      allow(loan.loan_general).to receive(:loan_events).and_return(loan_event)
      expect(subject.redisclosure_date).to eq("03/01/2015")
    end

    it "should return nil when there is no matching entry" do
      loan_event = double("LoanEvent")
      allow(loan_event).to receive(:where).with({ event_description: 'DocMagic Redisclosure Package Request'}).and_return([])
      allow(loan).to receive(:loan_general).and_return(loan_general)
      allow(loan.loan_general).to receive(:loan_events).and_return(loan_event)
      expect(subject.redisclosure_date).to be_nil
    end
  end

  describe "Redisclosure Date Plus Six" do
    loan_general = FactoryGirl.build_stubbed(:loan_general)
    it "should return rediscosure date plus 6 business days" do
      loan_event = double("LoanEvent")
      allow(loan_event).to receive(:where).with({ event_description: 'DocMagic Redisclosure Package Request'}).and_return([double("LoanEvent", event_date: Date.new(2015,5,19))])
      allow(loan).to receive(:loan_general).and_return(loan_general)
      allow(loan.loan_general).to receive(:loan_events).and_return(loan_event)
      expect(subject.redisclosure_date_plus_six).to eq("05/27/2015")
    end

    it "should return nil when there is no entry for loan event" do
      loan_event = double("LoanEvent")
      allow(loan_event).to receive(:where).with({ event_description: 'DocMagic Redisclosure Package Request'}).and_return([])
      allow(loan).to receive(:loan_general).and_return(loan_general)
      allow(loan.loan_general).to receive(:loan_events).and_return(loan_event)
      expect(subject.redisclosure_date_plus_six).to be_nil
    end
  end

  describe "Appraisal One Sent Date" do
    it "should return the date when available" do
      loan.stub_chain(:underwriting_datum, appraisal_sent_to_borrower: Date.new(2015,4,20))
      expect(subject.appraisal_one_sent_date).to eq('04/20/2015')
    end
    it "should return nil when date is not available" do
      loan.stub_chain(:underwriting_datum)
      expect(subject.appraisal_one_sent_date).to be_nil
    end
  end

  describe "Appraisal One Sent Date Plus Three" do
    it "should return adding 3 business days to appraisal one sent date" do
      loan.stub_chain(:underwriting_datum, appraisal_sent_to_borrower: Date.new(2015,5,18))
      expect(subject.appraisal_one_sent_date_plus_three).to eq('05/21/2015')
    end
    it "should take next business day when the resulting day is saturday" do
      loan.stub_chain(:underwriting_datum, appraisal_sent_to_borrower: Date.new(2015,5,20))
      expect(subject.appraisal_one_sent_date_plus_three).to eq('05/26/2015')
    end
    it "should return nil when there is no value" do
      loan.stub_chain(:underwriting_datum)
      expect(subject.appraisal_one_sent_date_plus_three).to be_nil
    end
  end

  describe "Appraisal One Delivery Method" do
    [ [1, 'Email'],
      [2, 'Fax'],
      [3, 'In Person'],
      [5, 'Overnight'],
      [6, 'US Mail']
    ].each do |delivery_method, expected|
      it "should be #{expected} when appraisal delivery method is #{delivery_method}" do
        loan.stub_chain(:underwriting_datum, :appraisal_delivery_method).and_return(delivery_method)
        subject.appraisal_one_delivery_method.should == expected
      end
    end

    it "should return nil when the value does not match any of delivery methods" do
      loan.stub_chain(:underwriting_datum, appraisal_delivery_method: nil)
      expect(subject.appraisal_one_delivery_method).to be_nil
    end
  end

  describe "Appraisal Two Sent Date" do
    it "should return second appraisal sent date" do
      loan.stub_chain(:underwriting_datum, second_appraisal_sent_to_borrower: Date.new(2015,5,19))
      expect(subject.appraisal_two_sent_date).to eq('05/19/2015')
    end
    it "should return nil when there is no value" do
      loan.stub_chain(:underwriting_datum)
      expect(subject.appraisal_two_sent_date).to be_nil
    end
  end

  describe "Appraisal Two Send Date Plus Three" do
    it "should return adding 3 business days to appraisal two send date" do
      loan.stub_chain(:underwriting_datum, second_appraisal_sent_to_borrower: Date.new(2015,5,19))
      expect(subject.appraisal_two_sent_date_plus_three).to eq('05/22/2015')
    end
    it "should return nil when there is no value" do
      loan.stub_chain(:underwriting_datum)
      expect(subject.appraisal_two_sent_date_plus_three).to be_nil
    end
  end

  describe "Appraisal Two Sent Date Plus Six" do
    it "should return by adding 6 business days to appraisal date" do
      loan.stub_chain(:underwriting_datum, second_appraisal_sent_to_borrower: Date.new(2015,5,19))
      expect(subject.appraisal_two_sent_date_plus_six).to eq('05/27/2015')
    end
    it "should return nil when there is no value" do
      loan.stub_chain(:underwriting_datum)
      expect(subject.appraisal_two_sent_date_plus_six).to be_nil
    end
  end

  describe "Lock Borrower Credit Score" do
    it "should return if borrower_credit_score has value in it" do
      loan.stub_chain(:lock_loan_datum, borrower_credit_score: 760)
      expect(subject.lock_borrower_credit_score).to eq(760)
    end

    it "should retun nil if thete is borrower_credit_score present" do
      loan.stub_chain(:lock_loan_datum)
      expect(subject.lock_borrower_credit_score).to be_nil
    end
  end

  describe "Lock CoBorrower Credit Score" do
    it "should return if co borrower credit score has value in it" do
      loan.stub_chain(:lock_loan_datum, co_borrower_credit_score: 765)
      expect(subject.lock_co_borrower_credit_score).to eq(765)
    end

    it "should be nil if the co borrower has no credit score" do
      loan.stub_chain(:lock_loan_datum)
      expect(subject.lock_co_borrower_credit_score).to be_nil
    end
  end

  describe "UW Conditions Borrower Credit Score" do
    it "should return borrower credit score from underwriting_datum" do
      loan.stub_chain(:underwriting_datum, borrower_credit_score: 761)
      expect(subject.uw_conditions_borrower_credit_score).to eq(761)
    end
    it "should return nil if borrower credit score does not exist" do
      loan.stub_chain(:underwriting_datum)
      expect(subject.uw_conditions_borrower_credit_score).to be_nil
    end
  end

  describe "UW Conditions CoBorrower Credit Score" do
    it "should return co borrower credit score" do
      loan.stub_chain(:underwriting_datum, co_borrower_credit_score: 781)
      expect(subject.uw_conditions_co_borrower_credit_score).to eq(781)
    end
    it "should return nil when there is no co borrower credit score" do
      loan.stub_chain(:underwriting_datum)
      expect(subject.uw_conditions_co_borrower_credit_score).to be_nil
    end
  end  

  describe "Total Discount Fee Amount" do
    it "should return nil if there are no HUD lines" do
      allow(loan).to receive(:hud_lines).and_return([])
      expect(subject.total_discount_fee_amount).to be_nil
    end
    it "should return nil if there is no 802 HUD line" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ line_num: 1002, sys_fee_name: 'Discount Points', total_amt: 320 })
      hud_lines << OpenStruct.new({ line_num: 1007, sys_fee_name: 'Discount Points', total_amt: 240 })
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.total_discount_fee_amount).to be_nil
    end
    it "should return nil if the fee name is wrong" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ line_num: 1002, sys_fee_name: 'Discount Points', total_amt: 430 })
      hud_lines << OpenStruct.new({ line_num: 802, sys_fee_name: 'Originator Compensation - Lender Paid', total_amt: 65 })
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.total_discount_fee_amount).to be_nil
    end
    it "should return the total for a hud line of the correct line and fee" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ line_num: 1002, sys_fee_name: 'Originator Compensation - Lender Paid', total_amt: 100 })
      hud_lines << OpenStruct.new({ line_num: 802, sys_fee_name: 'Discount Points', total_amt: 250 , hud_type: 'GFE'})
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.total_discount_fee_amount).to eq(250)
    end
    context "when loan is TRID loan" do
      before {allow(loan).to receive(:trid_loan?).and_return(true)}
      it "should return nil if the fee name is not matching" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Originator Compensation - Lender Paid')]}
        expect(subject.total_discount_fee_amount).to be_nil
      end

      it "should return total amount for hud line when fee name matches" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Discount Points', total_amt: BigDecimal.new('200.01'), hud_type: 'GFE') ]}
        expect(subject.total_discount_fee_amount).to eq(200.01)
      end
    end
  end

  describe ".mansion_tax_amount" do
    it "should return total_amt when System fee name 'Mansion Tax' and hud type GFE " do
      loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Mansion Tax', total_amt: BigDecimal.new('134.01')), build_stubbed(:hud_line, sys_fee_name: 'Mansion Tax', total_amt: BigDecimal.new('345.01'), hud_type: 'GFE') ]}       
      expect(subject.mansion_tax_amount).to eq(345.01)
    end

    it "should return nil when System Fee name matches Mansion Tax and no hud matches" do
      loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Mansion Tax', total_amt: BigDecimal.new('134.01'))]}
      expect(subject.mansion_tax_amount).to be_nil
    end
  end

  describe "Total Origination Fee Amount" do
    it "should return nil if there are no HUD lines" do
      allow(loan).to receive(:hud_lines).and_return([])
      expect(subject.total_origination_fee_amount).to be_nil
    end
    context "when loan is TRID loan" do
      before {allow(loan).to receive(:trid_loan?).and_return(true)}
      it "should return nil if the fee name is not matching" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Originator Compensation - Lender Paid', total_amt: BigDecimal.new('200.01'))]}
        expect(subject.total_origination_fee_amount).to be_nil
      end

      it "should return total amount for hud line when fee name matches" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Discount fee', total_amt: BigDecimal.new('200.01')), build_stubbed(:hud_line, sys_fee_name: 'Broker Compensation', total_amt: BigDecimal.new('123.01'), hud_type: 'GFE') ]}
        expect(subject.total_origination_fee_amount).to eq(123.01)
      end
    end
  end

  describe "Administration Fee" do
    context "when loan is TRID loan" do
      before { allow(loan).to receive(:trid_loan?).and_return(true) }

      it "should return nil if the fee name is not matching" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Recording Fees', total_amt: BigDecimal.new('200.01'))]}
        expect(subject.administration_fee).to be_nil
      end

      it "should return total amount for hud line when fee name matches" do
        loan.stub hud_lines: [
          build_stubbed(:hud_line, sys_fee_name: 'Administration Fee', total_amt: BigDecimal.new('200.02'), hud_type: 'HUD'),
          build_stubbed(:hud_line, sys_fee_name: 'Administration Fee', total_amt: BigDecimal.new('200.01'), hud_type: 'GFE'),
          build_stubbed(:hud_line, sys_fee_name: 'Recording Fees', total_amt: BigDecimal.new('300.01'))
        ]
        expect(subject.administration_fee).to eq(200.01)
      end
    end
  end

  describe "Recording Fee Amount" do
    it "should return nil if the fee name is not matching" do
      loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Administration Fee', total_amt: BigDecimal.new('200.01'))]}
      expect(subject.recording_fee_amount).to be_nil
    end

    it "should return total amount for hud line when fee name matches" do
      base = {
        sys_fee_name: "something with the word recording in it",
        hud_type: "GFE",
        total_amt: 100,
      }
      loan.stub hud_lines: [
        build_stubbed(:hud_line, base),
        build_stubbed(:hud_line, base.merge(sys_fee_name: "another recording fee")),
        build_stubbed(:hud_line, base.merge(sys_fee_name: "GRMA")),  #special case, include this too
        build_stubbed(:hud_line, base.merge(sys_fee_name: "does not have that word")),
        build_stubbed(:hud_line, base.merge(hud_type: "HUD", total_amt: 101)),
      ]

      expect(subject.recording_fee_amount).to eq(300)
    end
  end

  describe "Lender Credit Percentage" do
    it "should return nil if there are no HUD lines" do
      allow(loan).to receive(:hud_lines).and_return([])
      expect(subject.lender_credit_percentage).to be_nil
    end
    it "should return nil if there is no 827 HUD line" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ line_num: 1002, sys_fee_name: 'Lender Credit', rate_perc: 0.23 })
      hud_lines << OpenStruct.new({ line_num: 1007, sys_fee_name: 'Discount fee', rate_perc: 0.00 })
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.lender_credit_percentage).to be_nil
    end
    it "should return nil if the fee name is wrong" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ line_num: 827, sys_fee_name: 'Origination fee', rate_perc: 0.12 })
      hud_lines << OpenStruct.new({ line_num: 827, sys_fee_name: 'Originator Compensation - Lender Paid', rate_perc: 0.15 })
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.lender_credit_percentage).to be_nil
    end
    it "should return the total for a hud line of the correct line and fee" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ line_num: 1002, sys_fee_name: 'Originator Compensation - Lender Paid', rate_perc: 0.20 })
      hud_lines << OpenStruct.new({ line_num: 827, sys_fee_name: 'Lender Credit', rate_perc: 0.33 ,  hud_type: 'GFE'})
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.lender_credit_percentage).to eq(0.33)
    end
    context "when loan is TRID loan" do
      before {allow(loan).to receive(:trid_loan?).and_return(true)}
      it "should return nil if the fee name is not matching" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Originator Compensation - Lender Paid', rate_perc: 0.20)]}
        expect(subject.lender_credit_percentage).to be_nil
      end

      it "should return total amount for hud line when fee name matches" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Lender Credit', rate_perc: BigDecimal.new('12.34'), hud_type: 'GFE'), build_stubbed(:hud_line, sys_fee_name: 'Origination fee', total_amt: BigDecimal.new('123.01')) ]}
        expect(subject.lender_credit_percentage).to eq(12.34)
      end
    end
  end

  describe "Total Lender Credit Amount" do
    it "should return nil if there are no HUD lines" do
      allow(loan).to receive(:hud_lines).and_return([])
      expect(subject.total_lender_credit_amount).to be_nil
    end
    it "should return nil if there is no 827 HUD line" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ line_num: 1002, sys_fee_name: 'Lender Credit', total_amt: 100 })
      hud_lines << OpenStruct.new({ line_num: 1007, sys_fee_name: 'Discount fee', total_amt: 50 })
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.total_lender_credit_amount).to be_nil
    end
    it "should return nil if the fee name is wrong" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ line_num: 827, sys_fee_name: 'Origination fee', total_amt: 150 })
      hud_lines << OpenStruct.new({ line_num: 827, sys_fee_name: 'Originator Compensation - Lender Paid', total_amt: 200 })
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.total_lender_credit_amount).to be_nil
    end
    it "should return the total for a hud line of the correct line and fee" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ line_num: 1002, sys_fee_name: 'Originator Compensation - Lender Paid', total_amt: 250 })
      hud_lines << OpenStruct.new({ line_num: 827, sys_fee_name: 'Lender Credit', total_amt: 300, hud_type: 'GFE' })
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.total_lender_credit_amount).to eq(300)
    end
    context "when loan is not a TRID loan" do
      before {allow(loan).to receive(:trid_loan?).and_return(false)}
      it "should return nil if the fee name is not matching" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Originator Compensation - Lender Paid', total_amt: 0.20)]}
        expect(subject.total_lender_credit_amount).to be_nil
      end

      it "should return total amount for hud line when fee name matches" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, line_num: 827, sys_fee_name: 'Lender Credit', total_amt: BigDecimal.new('12.34'), hud_type: 'GFE'), build_stubbed(:hud_line, sys_fee_name: 'Origination fee', total_amt: BigDecimal.new('123.01')) ]}
        expect(subject.total_lender_credit_amount).to eq(12.34)
      end
    end
    context "when loan is TRID loan" do
      before {allow(loan).to receive(:trid_loan?).and_return(true)}
      it "should return nil if the fee name is not matching" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Originator Compensation - Lender Paid', total_amt: 0.20)]}
        expect(subject.total_lender_credit_amount).to be_nil
      end

      it "should return total amount for hud line when fee name matches" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Lender Credit', total_amt: BigDecimal.new('12.34'), hud_type: 'GFE'), build_stubbed(:hud_line, sys_fee_name: 'Origination fee', total_amt: BigDecimal.new('123.01')) ]}
        expect(subject.total_lender_credit_amount).to eq(12.34)
      end
    end

  end

  describe "Downloaded Borrower Credit Score" do
    
    it "should return borrower credit score with borrower_id BRW1" do
      borrower = double("Borrower")
      borrower = build_stubbed(:borrower, borrower_id: 'BRW1', equifax_credit_score: 670, experian_credit_score: 660, trans_union_credit_score: 650)
      allow(loan.borrowers).to receive(:where).with({ borrower_id: 'BRW1'}).and_return [borrower]
      expect(subject.downloaded_borrower_credit_score).to eq(660)
    end
    it "should return nil when there is no entry with BRW1" do
      borrower = double("Borrower")
      allow(borrower).to receive(:where).with({ borrower_id: 'BRW1'}).and_return([])
      allow(loan).to receive(:borrowers).and_return(borrower)
      expect(subject.downloaded_borrower_credit_score).to be_nil
    end
  end

  describe "Total Originator Compensation Amount" do
    it "should return nil if there are no HUD lines" do
      allow(loan).to receive(:hud_lines).and_return([])
      expect(subject.total_originator_compensation_amount).to be_nil
    end
    context "Calculates same way for both pre trid and post trid loans" do
      before {allow(loan).to receive(:trid_loan?).and_return(true)}
      it "should return nil when the fee name does not match" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Originator Compensation', total_amt: BigDecimal.new('100'))]}
        expect(subject.total_originator_compensation_amount).to be_nil
      end

      it "should return total amount if the fee name matches" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Lender Paid Broker Compensation', total_amt: BigDecimal.new("100.25"), hud_type: 'GFE'), build_stubbed(:hud_line, sys_fee_name: "Originator Compensation", total_amt: BigDecimal.new("100.2"))]}
        expect(subject.total_originator_compensation_amount).to eq(100.25)
      end
    end
  end

  describe "Total Premium Pricing Amount" do
    it "should return nil if there are no HUD lines" do
      allow(loan).to receive(:hud_lines).and_return([])
      expect(subject.total_premium_pricing_amount).to be_nil
    end
    it "should return nil if there is no 808 HUD line" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ line_num: 1002, sys_fee_name: 'Premium Pricing', total_amt: 320 })
      hud_lines << OpenStruct.new({ line_num: 1007, sys_fee_name: 'Originator Compensation - Lender Paid', total_amt: 240 })
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.total_premium_pricing_amount).to be_nil
    end
    it "should return nil if the fee name is wrong" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ line_num: 1002, sys_fee_name: 'Premium Pricing', total_amt: 430 })
      hud_lines << OpenStruct.new({ line_num: 808, sys_fee_name: 'Lender Paid', total_amt: 65 })
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.total_premium_pricing_amount).to be_nil
    end
    it "should return the total for a hud line of the correct line and fee" do
      hud_lines = [
        OpenStruct.new({ line_num: 808, sys_fee_name: 'Premium Pricing', total_amt: 900, hud_type: 'HUD' }),
        OpenStruct.new({ line_num: 1002, sys_fee_name: 'Lender Paid', total_amt: 100, hud_type: 'GFE' }),
        OpenStruct.new({ line_num: 808, sys_fee_name: 'Premium Pricing', total_amt: 250, hud_type: 'GFE' }),
      ]
      allow(loan).to receive(:trid_loan?).and_return(true)
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.total_premium_pricing_amount).to eq(250)
    end

    context "when it is a TRID loan" do
      before {allow(loan).to receive(:trid_loan?).and_return(true)}
      it "should return nil when the fee name does not match" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Originator Compensation - Lender Paid')]}
        expect(subject.total_premium_pricing_amount).to be_nil
      end

      it "should return total amount if the fee name matches" do
        loan.stub hud_lines: [
          build_stubbed(:hud_line, sys_fee_name: 'Premium Pricing', total_amt: BigDecimal.new("304.25"), hud_type: "HUD"),
          build_stubbed(:hud_line, sys_fee_name: 'Premium Pricing', total_amt: BigDecimal.new("303.25"), hud_type: "GFE"),
          build_stubbed(:hud_line, sys_fee_name: "Discount fee", total_amt: BigDecimal.new("100.2"), hud_type: "GFE")
        ]
        expect(subject.total_premium_pricing_amount).to eq(303.25)
      end
    end

    context "when it is not a TRID loan" do
      before {allow(loan).to receive(:trid_loan?).and_return(false)}
      it "should return nil when the fee name does not match" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Originator Compensation - Lender Paid')]}
        expect(subject.total_premium_pricing_amount).to be_nil
      end

      it "should return total amount if the fee name matches" do
        loan.stub hud_lines: [
          build_stubbed(:hud_line, line_num: 827, sys_fee_name: 'Lender Credit', total_amt: BigDecimal.new("303.25"), hud_type: "GFE"),
          build_stubbed(:hud_line, sys_fee_name: "Discount fee", total_amt: BigDecimal.new("100.2"), hud_type: "GFE")
        ]
        expect(subject.total_premium_pricing_amount).to eq(303.25)
      end
    end

  end

  describe "Downloaded CoBorrower Credit Score" do
    it "should return the co borrower middle credit score" do
      borrowers = [build_stubbed(:borrower, borrower_id: 'BRW2', equifax_credit_score: 670, experian_credit_score: 660, trans_union_credit_score: 650), build_stubbed(:borrower, borrower_id: 'BRW3', equifax_credit_score: 872, experian_credit_score: 850, trans_union_credit_score: 880)]
      loan.stub(:borrowers) {borrowers}
      allow(loan.borrowers).to receive(:where).with(any_args).and_return borrowers
      expect(subject.downloaded_co_borrower_credit_score).to eq(660)
    end
    it "should return nil when there are no co borrowers" do
      borrowers = [build_stubbed(:borrower, borrower_id: 'BRW1', equifax_credit_score: 670, experian_credit_score: 660, trans_union_credit_score: 650)]
      loan.stub(:borrowers) {borrowers}
      allow(loan.borrowers).to receive(:where).with(any_args).and_return []
      expect(subject.downloaded_co_borrower_credit_score).to be_nil
    end
  end

  describe "Rate Lock Request Originator Compensation" do
    it "should return Lender Paid" do
      datum = double()
      allow(loan).to receive(:lock_loan_datum).and_return(datum)
      allow(datum).to receive(:originator_compensation).and_return('2')
      expect(subject.rate_lock_request_originator_compensation).to eq('Lender Paid')
    end

    it "should return Borrower Paid" do
      datum = double()
      allow(loan).to receive(:lock_loan_datum).and_return(datum)
      allow(datum).to receive(:originator_compensation).and_return('1')
      expect(subject.rate_lock_request_originator_compensation).to eq('Borrower Paid')
    end

    it "should recognize allowed value as a number" do
      datum = double()
      allow(loan).to receive(:lock_loan_datum).and_return(datum)
      allow(datum).to receive(:originator_compensation).and_return(1)
      expect(subject.rate_lock_request_originator_compensation).to eq('Borrower Paid')
    end

    it "should return nil when the value is unknown" do
      datum = double()
      allow(loan).to receive(:lock_loan_datum).and_return(datum)
      allow(datum).to receive(:originator_compensation).and_return('foo')
      expect(subject.rate_lock_request_originator_compensation).to be_nil
    end

    it "should return nil when there is no value" do
      datum = double()
      allow(loan).to receive(:lock_loan_datum).and_return(datum)
      allow(datum).to receive(:originator_compensation).and_return(nil)
      expect(subject.rate_lock_request_originator_compensation).to be_nil
    end
  end

  describe "Originator Compensation Type" do
    before { loan.stub(channel: "W0-Wholesale Standard") }
    
    it "should return nil when there are no custom_fields for loan" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with({form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionCompType"}).and_return([])
      allow(custom_field).to receive(:where).with({form_unique_name: "Wholesale Initial Disclosure Request", attribute_unique_name: "Comp Type"}).and_return([])
      allow(loan).to receive(:custom_fields).and_return(custom_field)
      expect(subject.originator_compensation_type).to be_nil
    end

    it "should return Lender Paid when channel is not W0-Wholesale Standard" do
      loan.stub(channel: "Retail Standard") 
      expect(subject.originator_compensation_type).to eq "Lender Paid"
    end

    describe "should return value from the form Submit File to UW" do
      [ ['Borrower Paid', 'Borrower Paid'],
        ['Lender Paid', 'Lender Paid'],
      ].each do |attr_val, expect_val|
        it "should return #{expect_val} when attribute value is #{attr_val}" do
          custom_field = double("CustomField")
          allow(custom_field).to receive(:where).with({form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionCompType"}).and_return([OpenStruct.new({attribute_value: attr_val})])
          allow(loan).to receive(:custom_fields).and_return(custom_field)

          expect(subject.originator_compensation_type).to eq(expect_val)
        end
      end
    end

    describe "should return value from the form Wholesale Initial Disclosure Request when Submit File to UW has no value" do
      [ ['Borrower', 'Borrower Paid'],
        ['Lender', 'Lender Paid'],
        ['Please Select', nil]
      ].each do |attr_val, expect_val|
        it "should return #{expect_val} when attribute value is #{attr_val}" do
          custom_field = double("CustomField")
          allow(custom_field).to receive(:where).with({form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionCompType"}).and_return([])
          allow(custom_field).to receive(:where).with({form_unique_name: "Wholesale Initial Disclosure Request", attribute_unique_name: "Comp Type"}).and_return([OpenStruct.new({attribute_value: attr_val})])
          allow(loan).to receive(:custom_fields).and_return(custom_field)

          expect(subject.originator_compensation_type).to eq(expect_val)
        end
      end
    end
  end

  describe "Originator Compensation Percentage" do
    it "should return nil if no 826 hud line" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ line_num: 1002, sys_fee_name: 'Originator Compensation - Lender Paid', rate_perc: 0.10 })
      hud_lines << OpenStruct.new({ line_num: 1007, sys_fee_name: 'Originator Compensation - Lender Paid', rate_perc: 0.25 })
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.originator_compensation_percentage).to be_nil
    end

    it "should return nil if fee name is wrong" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ line_num: 1002, sys_fee_name: 'Originator Compensation - Lender Paid', rate_perc: 0.27 })
      hud_lines << OpenStruct.new({ line_num: 826, sys_fee_name: 'Origination fee', rate_perc: 0.19 })
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.originator_compensation_percentage).to be_nil
    end

    it "should return rate percent if line and fee name are correct" do
      hud_lines = Array.new
      hud_lines << OpenStruct.new({ line_num: 1002, sys_fee_name: 'Origination fee', rate_perc: 0.28 })
      hud_lines << OpenStruct.new({ line_num: 826, sys_fee_name: 'Originator Compensation - Lender Paid', rate_perc: 0.12, hud_type: 'GFE' })
      allow(loan).to receive(:hud_lines).and_return(hud_lines)
      expect(subject.originator_compensation_percentage).to eq(0.12)
    end

    context "when it is a TRID loan" do
      before {allow(loan).to receive(:trid_loan?).and_return(true)}
      it "should return nil when the fee name does not match" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Originator Compensation', total_amt: BigDecimal.new('100'))]}
        expect(subject.originator_compensation_percentage).to be_nil
      end

      it "should return total amount if the fee name matches" do
        loan.stub_chain(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: 'Originator Compensation - Lender Paid', rate_perc: BigDecimal.new("100.25"), hud_type: 'GFE'), build_stubbed(:hud_line, sys_fee_name: "Originator Compensation", rate_perc: BigDecimal.new("100.2"))]}
        expect(subject.originator_compensation_percentage).to eq(100.25)
      end
    end

  end

  describe "Appraisal One Sent Date Plus Six" do
    it "should return nil if there is no data for Appraisal sent to borrower " do
      loan.stub_chain(:underwriting_datum)
      expect(subject.appraisal_one_sent_date_plus_six).to be_nil
    end

    it "should return adding 6 business days to appraisal one sent date" do
      loan.stub_chain(:underwriting_datum, appraisal_sent_to_borrower: Date.new(2015,6,29))
      expect(subject.appraisal_one_sent_date_plus_six).to eq('07/07/2015')
    end
  end

  describe "Appraisal Consent to Waive Date" do
    it "should return nil when the consent_to_waive_delivery_received is not present." do
      loan.stub(:underwriting_datum)
      expect(subject.appraisal_consent_to_waive_date).to be_nil
    end
    it "should return date value present in consent_to_waive_delivery_received" do
      loan.stub_chain(:underwriting_datum, consent_to_waive_delivery_received: DateTime.new(2015,1,1))
      expect(subject.appraisal_consent_to_waive_date).to eq('01/01/2015')
    end
  end

  describe "Appraisal Two Delivery Method" do
    [ [1, 'Email'],
      [2, 'Fax'],
      [3, 'In Person'],
      [5, 'Overnight'],
      [6, 'US Mail']
    ].each do |delivery_method, expected|
      it "should be #{expected} when appraisal two delivery method is #{delivery_method}" do
        loan.stub_chain(:underwriting_datum, :second_appraisal_delivery_method).and_return(delivery_method)
        subject.appraisal_two_delivery_method.should == expected
      end
    end
    it "should return nil when the value does not match any of delivery methods" do
      loan.stub_chain(:underwriting_datum, second_appraisal_delivery_method: nil)
      expect(subject.appraisal_two_delivery_method).to be_nil
    end
  end

  describe "HARP Type of MI" do
    it "should return Required Field Please Select when the value is null" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with({attribute_label_description: "If this is a HARP Loan, what is the type of current MI?"}).and_return([double("CustomField", attribute_value: 'null')])
      allow(loan).to receive(:custom_fields).and_return(custom_field)
      expect(subject.harp_type_of_mi).to eq("Required Field Please Select")
    end

    [ ['Non Harp','This is a non HARP Loan'],
    ['Borrower Paid Monthly', 'Borrower Paid Monthly MI'],
    ['Borrower Paid Single', 'Borrower Paid Single Premium - Paid Up Front'],
    ['Lender Paid Single', 'Lender Paid Single Premium - Paid Up Front'],
    ['No MI', 'No MI is required on the AUS'],
    ['MI Cancelled', 'MI was cancelled documentation provided in imaging']].each do |attributevalue, expected|
      it "when attribute value is #{attributevalue} should return #{expected}" do
        custom_field = double("CustomField")
        allow(custom_field).to receive(:where).with({attribute_label_description: "If this is a HARP Loan, what is the type of current MI?"}).and_return([double("CustomField", attribute_value: attributevalue)])
        allow(loan).to receive(:custom_fields).and_return(custom_field)
        expect(subject.harp_type_of_mi).to eq(expected)
      end
    end

    context "when it is TRID loan" do
      before {allow(loan).to receive(:trid_loan?).and_return(true)}

      context "when there is something in Submit File to UW" do
        [ ["Non Harp", "This is a non HARP Loan"],
          ["Borrower Paid Monthly", "Borrower Paid Monthly MI"],
          ["Borrower Paid Single", "Borrower Paid Single Premium - Paid Up Front"],
          ["Lender Paid Single", "Lender Paid Single Premium - Paid Up Front"],
          ["No MI", "No MI is required on the AUS"],
          ["MI Cancelled", "MI was cancelled documentation provided in imaging"]
        ].each do |attr_val, expect_val|
          it "should return #{expect_val} when wholesale attribute value is P and UW attribute value is #{attr_val}" do
            custom_field = double
            allow(custom_field).to receive(:where).with({form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionHarpMI"}).and_return([OpenStruct.new({attribute_value: attr_val})])
            allow(loan).to receive(:custom_fields).and_return(custom_field)

            expect(subject.harp_type_of_mi).to eq(expect_val)
          end
        end

      end

      context "when it is wholesale" do
        before {allow(loan).to receive(:channel).and_return("W0-Wholesale Standard")}

        [ ["Non HARP", "This is a non HARP Loan"],
          ["Borrower Paid, Monthly MI", "Borrower Paid Monthly MI"],
          ["Borrower Paid, Single Premium - Paid Up Front", "Borrower Paid Single Premium - Paid Up Front"],
          ["Lender Paid, Single Premium - Paid Up Front", "Lender Paid Single Premium - Paid Up Front"],
          ["No MI is required on the AUS", "No MI is required on the AUS"],
          ["MI was cancelled, documentation provided in imagin", "MI was cancelled documentation provided in imaging"]
        ].each do |attr_val, expect_val|
          it "should return #{expect_val} when attribute value is #{attr_val}" do
            custom_field = double
            allow(custom_field).to receive(:where).with({form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionHarpMI"}).and_return([OpenStruct.new({attribute_value: attr_val})])
            allow(custom_field).to receive(:where).with({form_unique_name: "Wholesale Initial Disclosure Request", attribute_unique_name: "If Harp Loan"}).and_return([OpenStruct.new({attribute_value: attr_val})])
            allow(loan).to receive(:custom_fields).and_return(custom_field)

            expect(subject.harp_type_of_mi).to eq(expect_val)
          end
        end
      end

      context "when it is not wholesale" do
        before {allow(loan).to receive(:channel).and_return("A0-Affiliate Standard")}
        [ ["Non HARP", "This is a non HARP Loan"],
          ["Borrower Paid, Monthly MI", "Borrower Paid Monthly MI"],
          ["Borrower Paid, Single Premium - Paid Up Front", "Borrower Paid Single Premium - Paid Up Front"],
          ["Lender Paid, Single Premium - Paid Up Front", "Lender Paid Single Premium - Paid Up Front"],
          ["No MI is required on the AUS", "No MI is required on the AUS"],
          ["MI was cancelled, documentation provided in imagin", "MI was cancelled documentation provided in imaging"]
        ].each do |attr_val, expect_val|
          it "should return #{expect_val} when attribute value is #{attr_val}" do
            custom_field = double
            allow(custom_field).to receive(:where).with({form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionHarpMI"}).and_return([OpenStruct.new({attribute_value: attr_val})])
            allow(custom_field).to receive(:where).with({form_unique_name: "Retail Initial Disclosure Request", attribute_unique_name: "If Harp Loan"}).and_return([OpenStruct.new({attribute_value: attr_val})])
            allow(loan).to receive(:custom_fields).and_return(custom_field)

            expect(subject.harp_type_of_mi).to eq(expect_val)
          end
        end
      end
    end
  end

  describe "Requested mortgage insurance type" do
    [ ['null', 'Required Field Please Select'],
    ['Monthly', 'Borrower Paid MONTHLY'],
    ['None', 'No MI Required'],
    ['Lender', 'Lender Paid SINGLE Premium (LPMI)'],
    ['Split', 'Borrower Paid SPLIT Premium MI'],
    ['Not Required', 'No MI Required'],
    ['Lender Paid SINGLE Premium', 'Lender Paid SINGLE Premium (LPMI)'],
    ['Required Field Please Select...', 'Required Field Please Select'],
    ['Borrower Paid SPLIT Premium MI', 'Borrower Paid SPLIT Premium MI']
    ].each do |attr_value, expected|
      it "should return #{expected} when attribute value #{attr_value}" do
        custom_field = double("CustomField")
        allow(custom_field).to receive(:where).with({attribute_label_description: "If MI (Conventional Loans Only)  is required, what type of MI is being requested?"}).and_return([double("CustomField", attribute_value: attr_value)])
        allow(loan).to receive(:custom_fields).and_return(custom_field)
        expect(subject.requested_mortgage_insurance_type).to eq(expected)
      end
    end

    context "When it is TRID loan" do
      before { allow(loan).to receive(:trid_loan?).and_return(true) }

      context "when there is something in Submit File to UW" do
        [ ["Lender", "Lender Paid SINGLE Premium (LPMI)"],
          ["Monthly", "Borrower Paid MONTHLY"],
          ["None", "No MI Required"],
          ['P', nil]
        ].each do |attr_val, expect_val|
          it "should return #{expect_val} when attribute value is P and UW attribute value is #{attr_val}" do
            custom_field = double
            allow(custom_field).to receive(:where).with({form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionMIType"}).and_return([OpenStruct.new({attribute_value: attr_val})])
            allow(loan).to receive(:custom_fields).and_return(custom_field)

            expect(subject.requested_mortgage_insurance_type).to eq(expect_val)
          end
        end
      end

      context "when the channel is wholesale" do
        before {allow(loan).to receive(:channel).and_return("W0-Wholesale Standard")}

        [ ["L", "Lender Paid SINGLE Premium (LPMI)"],
          ["B", "Borrower Paid MONTHLY"],
          ["NA", "No MI Required"],
          ['P', nil]
        ].each do |attr_val, expect_val|
          it "should return #{expect_val} for #{attr_val}" do
            custom_field = double
            allow(custom_field).to receive(:where).with({form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionMIType"}).and_return([])
            allow(custom_field).to receive(:where).with({form_unique_name: "Wholesale Initial Disclosure Request", attribute_unique_name: "MI Type"}).and_return([OpenStruct.new({attribute_value: attr_val})])
            allow(loan).to receive(:custom_fields).and_return(custom_field)

            expect(subject.requested_mortgage_insurance_type).to eq(expect_val)
          end
        end
      end

      context "when the channel is not wholesale" do
        before {allow(loan).to receive(:channel).and_return("A0-Affiliate Standard")}

        [ ["L", "Lender Paid SINGLE Premium (LPMI)"],
          ["B", "Borrower Paid MONTHLY"],
          ["NA", "No MI Required"],
          ['P', nil]
        ].each do |attr_val, expect_val|
          it "should return #{expect_val} for #{attr_val}" do 
            custom_field = double
            allow(custom_field).to receive(:where).with({form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionMIType"}).and_return([])
            allow(custom_field).to receive(:where).with({form_unique_name: "Retail Initial Disclosure Request", attribute_unique_name: "MIType"}).and_return([OpenStruct.new({attribute_value: attr_val})])
            allow(loan).to receive(:custom_fields).and_return(custom_field)

            expect(subject.requested_mortgage_insurance_type).to eq(expect_val)
          end
        end
      end
    end
  end

  describe "Notice of Special Flood Hazards Delivery Date" do
    it "should return nil when service order does not have sent date or there are no service orders" do
      service_order = double("ServiceOrder")
      allow(service_order).to receive(:where).and_return([])
      loan.stub_chain(:service_orders) {service_order}
      expect(subject.notice_of_special_flood_hazards_delivery_date).to be_nil
    end
    it "should return first available sent date of service order" do
      service_order = double("ServiceOrder")
      allow(service_order).to receive(:where).and_return([double("ServiceOrder", sent_method: 'Postal', sent_date: Date.new(2015,4,23))])
      loan.stub_chain(:service_orders) {service_order}
      expect(subject.notice_of_special_flood_hazards_delivery_date).to eq('04/23/2015')
    end
  end

  describe "Appraisal Type" do
    it "should return Actual when PropertyAppraisedValueAmount  is present and PropertyEstimatedValueAmount not present" do
      loan.stub_chain(:transmittal_datum, property_appraised_value_amount: 100) 
      expect(subject.appraisal_type).to eq('Actual')
    end
    it "should return Estimated when PropertyEstimatedValueAmount is present" do
      loan.stub_chain(:transmittal_datum, property_estimated_value_amount: 200)
      expect(subject.appraisal_type).to eq('Estimated')

      loan.stub_chain(:transmittal_datum, property_appraised_value_amount: 100, property_estimated_value_amount: 200)
      expect(subject.appraisal_type).to eq('Estimated')
    end
    it "should return nil when both appraised val amount and estimated val amount are null" do
      loan.stub_chain(:transmittal_datum)
      expect(subject.appraisal_type).to be_nil
    end
  end

  describe "Appraisal Year Built" do
    let(:property) {FactoryGirl.build_stubbed(:property)}
    it "should return year if Appraisal year built is present in property" do
      loan.stub_chain(:property, structure_built_year: 1956)
      expect(subject.appraisal_year_built).to eq(1956)
    end
    it "should return if Appraisal year built is not present" do
      expect(subject.appraisal_year_built).to be_nil
    end
  end

  describe "Appraiser License State" do
    it "should return state if it is present" do
      loan.stub_chain(:transmittal_datum, appraiser_license_state: 'CA')
      expect(subject.appraiser_license_state).to eq('CA')
    end
    it "should return nil if the state is not present" do
      loan.stub_chain(:transmittal_datum)
      expect(subject.appraiser_license_state).to be_nil
    end
  end

  describe "Appraiser License Number" do
    it "should return license number id available" do
      loan.stub_chain(:transmittal_datum, appraiser_license_number: 'RL000491L')
      expect(subject.appraiser_license_number).to eq('RL000491L')
    end
    it "should return nil when license number is unavailable" do
      loan.stub_chain(:transmittal_datum)
      expect(subject.appraiser_license_number).to be_nil
    end
  end

  describe "Appraisal Company Name" do
    it "should return company name when present" do
      loan.stub_chain(:transmittal_datum, appraiser_company: 'Dart Appraisal')
      expect(subject.appraisal_company_name).to eq('Dart Appraisal')
    end

    it "should return nil when company name does not exist" do
      expect(subject.appraisal_company_name).to be_nil
    end
  end

  describe "Property Appraised Value" do
    it "should return property_appraised_value_amount value if it exists" do
      loan.stub_chain(:transmittal_datum, property_appraised_value_amount: 100)
      expect(subject.property_appraised_value).to eq(100.0)

       loan.stub(:transmittal_datum) {build_stubbed(:transmittal_datum, property_appraised_value_amount: 100, property_estimated_value_amount: 300)}
      expect(subject.property_appraised_value).to eq(100.0)
    end

    it "should return property_estimated_value_amount value if appraised value is nil" do
      loan.stub_chain(:transmittal_datum, property_estimated_value_amount: 300)
      expect(subject.property_appraised_value).to eq(300.0)
    end

    it "should return nil when both appraised and extimated value are nil" do
      loan.stub_chain(:transmittal_datum)
      expect(subject.property_appraised_value).to be_nil
    end
  end

  describe "Appraiser Name" do
    it "should return appraiser name if it exists" do
      loan.stub_chain(:transmittal_datum, appraiser_name: 'Foo Bob')
      expect(subject.appraiser_name).to eq('Foo Bob')
    end
    it "should return nil when appraiser name not present" do
      loan.stub_chain(:transmittal_datum)
      expect(subject.appraiser_name).to be_nil
    end
  end

  describe "Assets doc expiration date" do
    it "should return nil when there no conditions matching" do
      loan.stub(:underwriting_conditions) {[build_stubbed(:underwriting_condition, condition: 'Credit Expiration: 03/05/2011', status: "Pending")]}
      expect(subject.assets_doc_expiration_date).to be_nil
    end

    it "should return the expiration date when the condition matches Asset Expiration" do
      loan.stub(:underwriting_conditions) {[build_stubbed(:underwriting_condition, condition: 'Asset Expiration: 08/05/2015', status: "Pending")]}
      expect(subject.assets_doc_expiration_date).to eq("08/05/2015")
    end

    it "should return date when the condition is Assets Expiration also" do
      loan.stub(:underwriting_conditions) {[build_stubbed(:underwriting_condition, condition: 'Assets Expiration: 01/01/2015', status: "Pending")]}
      expect(subject.assets_doc_expiration_date).to eq("01/01/2015")
    end
  end

  describe "Property County Name" do
    it "should return nil when there is no county available" do
      loan.stub_chain(:property)
      expect(subject.property_county_name).to be_nil
    end

    it "should return county name" do
      loan.stub_chain(:property, county: 'SAN DIEGO')
      expect(subject.property_county_name).to eq('SAN DIEGO')
    end
  end

  describe "Closing Cost Expiration Date" do
    it "should return nil when date is nil" do
      allow(loan).to receive(:loan_general).and_return(loan_general)
      loan.loan_general.stub_chain(:lock_price, lock_expired_at: nil)
      expect(subject.closing_cost_expiration_date).to be_nil
    end

    it "should return date when date exists" do
      loan.stub loan_general: FactoryGirl.build_stubbed(:loan_general)
      loan.loan_general.stub_chain(:lock_price, lock_expired_at: DateTime.new(2015,1,1))
      expect(subject.closing_cost_expiration_date).to eq("01/01/2015")
    end
  end

  describe "LE Redisclosure Sent Date" do
    it "should return nil when GFERedisclosureDate is nil" do
      allow(loan).to receive(:loan_general).and_return(loan_general)
      loan.loan_general.stub_chain(:gfe_detail, gfe_redisclosure_date: nil)
      expect(subject.le_redisclosure_sent_date).to be_nil
    end

    it "should return date when GFERedisclosureDate has date" do
      loan.stub loan_general: FactoryGirl.build_stubbed(:loan_general)
      loan.loan_general.stub_chain(:gfe_detail, gfe_redisclosure_date: DateTime.new(2015,1,1))
      expect(subject.le_redisclosure_sent_date).to eq("01/01/2015")
    end
  end  

  describe "Pest Inspection Fee Amount" do
    it "should be the amount for the hud line with system fee name Pest Inspection Fee" do
      lines = [
        build_stubbed(:hud_line, sys_fee_name: 'Pest Inspection Fee', total_amt: BigDecimal.new('101'), hud_type: "HUD"),
        build_stubbed(:hud_line, sys_fee_name: 'Pest Inspection Fee', total_amt: BigDecimal.new('100'), hud_type: "GFE"),
      ]
      loan.stub hud_lines: lines
      expect(subject.pest_inspection_fee_amount).to eq 100.0
    end

    it "should be nil if there is no pest inspection fee line" do
      loan.stub hud_lines: [ build_stubbed(:hud_line, sys_fee_name: 'foo', total_amt: 1)]
      expect(subject.pest_inspection_fee_amount).to eq nil
    end
  end

  describe "Title Vendor Fee Amount" do
    it "should be nil if there are no matching hud lines" do
      loan.stub hud_lines: [ build_stubbed(:hud_line, sys_fee_name: 'foo', total_amt: 1)]
      expect(subject.title_vendor_fee_amount).to eq nil
    end

    it "should add the amounts of hud lines with Title and in ServicesYouCanShopFor and GFE" do
      lines = [
        build_stubbed(:hud_line, hud_type: 'GFE', sys_fee_name: 'Title blah blah', fee_category: "ServicesYouCanShopFor", total_amt: 100),
        build_stubbed(:hud_line, hud_type: 'GFE', sys_fee_name: 'Title something else', fee_category: "ServicesYouCanShopFor", total_amt: 200),
        build_stubbed(:hud_line, hud_type: 'GFE', sys_fee_name: 'not a title', fee_category: "ServicesYouCanShopFor", total_amt: 101),
        build_stubbed(:hud_line, hud_type: 'GFE', sys_fee_name: 'Title blah blah', fee_category: "some other category", total_amt: 102),
        build_stubbed(:hud_line, hud_type: 'HUD', sys_fee_name: 'Title something else', fee_category: "ServicesYouCanShopFor", total_amt: 200),
        build_stubbed(:hud_line, hud_type: 'GFE', sys_fee_name: 'Title something else', fee_category: "ServicesYouCanShopFor", total_amt: nil),
      ]
      loan.stub hud_lines: lines
      expect(subject.title_vendor_fee_amount).to eq 300.0
    end
  end

  describe "Survey Fee" do
    it "should be the amount for the hud line with matching system fee name" do
      lines = [
        build_stubbed(:hud_line, sys_fee_name: 'Survey Fee', total_amt: 101, hud_type: "HUD"),
        build_stubbed(:hud_line, sys_fee_name: 'Survey Fee', total_amt: 100, hud_type: "GFE"),
      ]
      loan.stub hud_lines: lines
      expect(subject.survey_fee_amount).to eq 100.0
    end

    it "should be nil if there is no matching hud line" do
      loan.stub hud_lines: [ build_stubbed(:hud_line, sys_fee_name: 'foo', total_amt: 1)]
      expect(subject.survey_fee_amount).to eq nil
    end
  end

  describe ".initial_cd_sent_to_borrower_date" do
    before {loan.stub loan_general: FactoryGirl.build_stubbed(:loan_general)}
    it "should return nil when cd_disclosure_date is nil" do
      loan.loan_general.stub_chain(:loan_detail, cd_disclosure_date: nil)
      expect(subject.initial_cd_sent_to_borrower_date).to be_nil
    end

    it "should return date when cd_disclosure_date has value" do
      loan.loan_general.stub_chain(:loan_detail, cd_disclosure_date: DateTime.new(2015,3,4))
      expect(subject.initial_cd_sent_to_borrower_date).to eq("03/04/2015")
    end
  end
  
  describe "No Lender Admin Fee LLPA Indicator" do
    before do
      loan.channel = Channel.wholesale.identifier
      loan.stub price_adjustments: [ 
        PriceAdjustment.new({label: "018 No Lender Admin Fee", amount: 0.2}, without_protection: true)
      ]
    end

    it "should return yes when wholesale and has a LLPA with value with the right label" do
      expect(subject.no_lender_admin_fee_llpa_indicator).to eq "Yes"
    end

    it "should be No if not wholesale" do
      loan.channel = Channel.retail.identifier
      expect(subject.no_lender_admin_fee_llpa_indicator).to eq "No"
    end

    it "should be No if there is no matching adjustment" do
      loan.stub price_adjustments: [ 
        PriceAdjustment.new({label: "something else", amount: 0.2}, without_protection: true)
      ]
      expect(subject.no_lender_admin_fee_llpa_indicator).to eq "No"
    end

    it "should be No if there is no matching adjustment" do
      loan.stub price_adjustments: [ 
        PriceAdjustment.new({label: "something else", amount: -0.8}, without_protection: true)
      ]
      expect(subject.no_lender_admin_fee_llpa_indicator).to eq "No"
    end

    it "should be No if the adjustment has no value" do
      loan.stub price_adjustments: [ 
        PriceAdjustment.new({label: "018 No Lender Admin Fee", amount: 0}, without_protection: true)
      ]
      expect(subject.no_lender_admin_fee_llpa_indicator).to eq "No"
    end
  end

  describe "Broker NMLS Number" do
    it "should be the interviewer.institution_nmls_id" do
      loan.stub_chain(:interviewer, :institution_nmls_id).and_return('abcd')
      expect(subject.broker_nmls_number).to eq "abcd"
    end

    it "should not break if the interviewer is missing" do
      loan.stub interviewer: nil
      expect(subject.broker_nmls_number).to eq nil
    end
  end

  describe "Loan Officer NMLS Number" do
    it "should be the interviewer.individual_nmls_id" do
      loan.stub_chain(:interviewer, :individual_nmls_id).and_return('abcd')
      expect(subject.loan_officer_nmls_number).to eq "abcd"
    end

    it "should not break if the interviewer is missing" do
      loan.stub interviewer: nil
      expect(subject.loan_officer_nmls_number).to eq nil
    end
  end

  describe ".initial_le_sent_date" do
    before {loan.stub loan_general: FactoryGirl.build_stubbed(:loan_general)}
    it "should return nil when there is no value for initial_gfe_disclosure_date" do
      loan.loan_general.stub_chain(:gfe_detail, initial_gfe_disclosure_date: nil)
      expect(subject.initial_le_sent_date).to be_nil
    end

    it "should return date when initial_gfe_disclosure_date has date in it" do
      loan.loan_general.stub_chain(:gfe_detail, initial_gfe_disclosure_date: DateTime.new(2014,5,6))
      expect(subject.initial_le_sent_date).to eq("05/06/2014")
    end
  end

  describe "Total Box G Months" do
    it "should be nil if there are no matching hud lines" do
      loan.stub hud_lines: [ build_stubbed(:hud_line, sys_fee_name: 'foo', total_amt: 1)]
      expect(subject.total_box_g_months).to eq nil
    end

    it "should add the number of months of hud lines with category InitialEscrowPaymentAtClosing" do
      lines = [
        build_stubbed(:hud_line, fee_category: "InitialEscrowPaymentAtClosing", num_months: 1, hud_type: 'GFE'),
        build_stubbed(:hud_line, fee_category: "InitialEscrowPaymentAtClosing", num_months: 2, hud_type: 'GFE'),
        build_stubbed(:hud_line, fee_category: "InitialEscrowPaymentAtClosing", num_months: 3, hud_type: 'HUD'),
        build_stubbed(:hud_line, fee_category: "InitialEscrowPaymentAtClosing", num_months: nil),
        build_stubbed(:hud_line, fee_category: "sldfjdsf", num_months: 101),
      ]
      loan.stub hud_lines: lines
      expect(subject.total_box_g_months).to eq 3
    end
  end

  describe "Is This A PreApproval" do
    it "should return nil when no custom field matched the form and attribute unique name" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with(form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionPreapproval").and_return([])
      allow(loan).to receive(:custom_fields).and_return(custom_field)
      expect(subject.is_this_atbd).to be_nil
    end

    [ ["Y", "Yes"],
      ["N", "No"],
      ["Required Field, Please Select...", ""]
    ].each do |value, expected| 
      it "should return #{expected} when attribute value is #{value}" do
        custom_field = double("CustomField")
        allow(custom_field).to receive(:where).with(form_unique_name: "Submit File to UW", attribute_unique_name: "UWSubmissionPreapproval").and_return([double("CustomField", attribute_value: value)])
        allow(loan).to receive(:custom_fields).and_return(custom_field)
        expect(subject.is_this_atbd).to eq expected
      end
    end
  end

  describe "Total Box G Amount" do
    it "should be nil if there are no matching hud lines" do
      loan.stub hud_lines: [ build_stubbed(:hud_line, sys_fee_name: 'foo', total_amt: 1)]
      expect(subject.total_box_g_amount).to eq nil
    end

    it "should add the total amts of matching hud lines" do
      lines = [
        build_stubbed(:hud_line, fee_category: "InitialEscrowPaymentAtClosing", total_amt: 100.01, hud_type: "GFE"),
        build_stubbed(:hud_line, fee_category: "InitialEscrowPaymentAtClosing", total_amt: 200.02, hud_type: "GFE"),
        build_stubbed(:hud_line, fee_category: "InitialEscrowPaymentAtClosing", total_amt: 200.02, hud_type: "GFE"),
        build_stubbed(:hud_line, fee_category: "InitialEscrowPaymentAtClosing", total_amt: nil, hud_type: "GFE"),
        build_stubbed(:hud_line, fee_category: "sldfjdsf", total_amt: 201, hud_type: "GFE"),
        build_stubbed(:hud_line, fee_category: "InitialEscrowPaymentAtClosing", total_amt: 202.02, hud_type: "HUD"),
      ]
      loan.stub hud_lines: lines
      expect(subject.total_box_g_amount).to eq 500.05   # 100.01 + 2*200.02
    end
  end

  describe "Transfer Tax Amount" do
    it "should be nil if there are no matching hud lines" do
      loan.stub hud_lines: [ build_stubbed(:hud_line, sys_fee_name: 'foo', total_amt: 1)]
      expect(subject.transfer_tax_amount).to eq nil
    end

    it "should be the total amount for all Tax lines in the TaxesAndOtherGovernmentFees category" do
      base = {
        fee_category: "TaxesAndOtherGovernmentFees",
        sys_fee_name: "something with the word tax in it",
        hud_type: "GFE",
        total_amt: 100,
      }
      lines = [
        build_stubbed(:hud_line, base),
        build_stubbed(:hud_line, base.merge(sys_fee_name: "another tax")),
        build_stubbed(:hud_line, base.merge(hud_type: "HUD", total_amt: 101)),
        build_stubbed(:hud_line, base.merge(fee_category: "something else", total_amt: 101)),
      ]
      loan.stub hud_lines: lines
      expect(subject.transfer_tax_amount).to eq 200
    end
  end

  describe "LE Credit Report Fee Amount" do
    it "should be nil if there are no matching hud lines" do
      loan.stub hud_lines: [ build_stubbed(:hud_line, sys_fee_name: 'foo', total_amt: 1)]
      expect(subject.le_credit_report_fee_amount).to eq nil
    end

    it "should be the amount for matching fee name with two decimals" do
      loan.stub hud_lines: [
        build_stubbed(:hud_line, sys_fee_name: "Credit Report", total_amt: 101, hud_type: 'HUD'),
        build_stubbed(:hud_line, sys_fee_name: "Credit Report", total_amt: 100, hud_type: 'GFE'),
      ]
      expect(subject.le_credit_report_fee_amount).to eq "100.00"
    end
  end

  describe "State Housing Document Prep Fee" do
    it "should return nil if no matching hud lines exist" do
      loan.stub hud_lines: [ build_stubbed(:hud_line, sys_fee_name: 'State Housing Doc Prep Fee', total_amt: BigDecimal.new('100'))]
      expect(subject.state_housing_document_prep_fee).to be_nil
    end

    it "should return total amount when there is matching hud lines" do
      loan.stub hud_lines: [
        build_stubbed(:hud_line, sys_fee_name: 'State Housing Doc Prep Fee', fee_category: "OriginationCharges", total_amt: BigDecimal.new('310'), hud_type: "HUD"),
        build_stubbed(:hud_line, sys_fee_name: 'Doc Prep Fee', fee_category: "OriginationCharges", total_amt: BigDecimal.new('300'), hud_type: "GFE"),
      ]
      expect(subject.state_housing_document_prep_fee).to eq(300)
    end

    it "should accept any fee name that ends with 'Doc Prep Fee'" do
      loan.stub hud_lines: [
        build_stubbed(:hud_line, sys_fee_name: 'Attorney Doc Prep Fee', fee_category: "OriginationCharges", total_amt: BigDecimal.new('245'), hud_type: "GFE"),
        build_stubbed(:hud_line, sys_fee_name: 'State Housing Doc Prep Fee', fee_category: "OriginationCharges", total_amt: BigDecimal.new('185'), hud_type: "HUD"),
      ]
      expect(subject.state_housing_document_prep_fee).to eq 245
    end

    it "should be able to handle hud lines with no fee name" do
      loan.stub hud_lines: [
        build_stubbed(:hud_line, sys_fee_name: nil, fee_category: "OriginationCharges", total_amt: BigDecimal.new('275'), hud_type: "GFE"),
        build_stubbed(:hud_line, sys_fee_name: 'Attorney Doc Prep Fee', fee_category: "OriginationCharges", total_amt: BigDecimal.new('245'), hud_type: "GFE"),
        build_stubbed(:hud_line, sys_fee_name: 'State Housing Doc Prep Fee', fee_category: "OriginationCharges", total_amt: BigDecimal.new('185'), hud_type: "HUD"),
      ]
      expect(subject.state_housing_document_prep_fee).to eq 245
    end

  end

  describe "LE Condo Questionnaire Fee Amount" do
    it "should be nil if there are no matching hud lines" do
      loan.stub hud_lines: [ build_stubbed(:hud_line, sys_fee_name: 'foo', total_amt: 1)]
      expect(subject.le_condo_questionnaire_fee_amount).to eq nil
    end

    it "should be the amount for matching fee name for gfe" do
      loan.stub hud_lines: [build_stubbed(:hud_line, sys_fee_name: "Condominium Questionnaire", total_amt: 100, hud_type: "GFE")]
      expect(subject.le_condo_questionnaire_fee_amount).to eq 100
    end

    it "should not use hud" do
      loan.stub hud_lines: [build_stubbed(:hud_line, sys_fee_name: "Condominium Questionnaire", total_amt: 100, hud_type: "HUD")]
      expect(subject.le_condo_questionnaire_fee_amount).to eq nil
    end
  end

  describe "LE Appraisal Fee Amount" do
    it "should be nil if there are no matching hud lines" do
      loan.stub hud_lines: [ build_stubbed(:hud_line, sys_fee_name: 'foo', total_amt: 1)]
      expect(subject.le_appraisal_fee_amount).to eq nil
    end

    it "should be the amount for matching fee name" do
      loan.stub hud_lines: [
        build_stubbed(:hud_line, sys_fee_name: "Appraisal Fee", total_amt: 101, hud_type: 'HUD'),
        build_stubbed(:hud_line, sys_fee_name: "Appraisal Fee", total_amt: 100, hud_type: 'GFE'),
      ]
      expect(subject.le_appraisal_fee_amount).to eq 100
    end
  end

  describe "Employee Loan Indicator" do
    before {loan.stub loan_general: FactoryGirl.build_stubbed(:loan_general)}
    it "should retuen Employee when employee indicator is true" do
      loan.loan_general.stub_chain(:additional_loan_datum, employee_loan_indicator: true)
      expect(subject.employee_loan_indicator).to eq "Employee"
    end

    it "should retuen Not Employee when employee indicator is false" do
      loan.loan_general.stub_chain(:additional_loan_datum, employee_loan_indicator: false)
      expect(subject.employee_loan_indicator).to eq "Not Employee"
    end
  end

  describe "Lock Discount Percentage" do
    it "should return nil if there is no entry for lock price" do
      loan.stub lock_price: nil
      expect(subject.lock_discount_percentage).to be_nil
    end

    it "should return abs value after subtraction if it is less than 0" do
      loan.stub_chain(:lock_price, net_price: 99)
      expect(subject.lock_discount_percentage).to eq 1
    end

    it "should return nil if the value after subtraction is greater than 0" do
      loan.stub_chain(:lock_price, net_price: 102)
      expect(subject.lock_discount_percentage).to be_nil
    end

    it "should round the percentage" do
      loan.stub_chain(:lock_price, net_price:  95.4334)
      expect(subject.lock_discount_percentage).to eq(4.567)
    end
  end

  describe "Lock Net Price" do
    it "should return nil if there is no entry for lock price" do
      loan.stub lock_price: nil
      expect(subject.lock_net_price).to be_nil
    end

    it "should return value" do
      loan.stub_chain(:lock_price, net_price: 102)
      expect(subject.lock_net_price).to eq 102
    end
  end

  describe "Attorney Doc Prep Fee" do
    it "should return if no matching records found" do
      loan.stub(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: "Credit report", total_amt: 200)]}
      expect(subject.attorney_doc_prep_fee).to be_nil
    end

    it "should return amount if it matches" do
      loan.stub :hud_lines => [
        build_stubbed(:hud_line, hud_type: 'HUD', sys_fee_name: "Attorney Doc Prep Fee", total_amt: 301),
        build_stubbed(:hud_line, hud_type: 'GFE', sys_fee_name: "Attorney Doc Prep Fee", total_amt: 300)
      ]
      expect(subject.attorney_doc_prep_fee).to eq 300
    end
  end

  describe "LE Flood Cert Fee Amount" do
    it "should return if no matching records found" do
      loan.stub(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: "sdlfjkds", total_amt: 200)]}
      expect(subject.le_flood_cert_fee_amount).to be_nil
    end

    it "should return amount if it matches" do
      loan.stub hud_lines: [
        build_stubbed(:hud_line, sys_fee_name: "Flood Determination Fee", total_amt: 301, hud_type: 'HUD'),
        build_stubbed(:hud_line, sys_fee_name: "Flood Determination Fee", total_amt: 300, hud_type: 'GFE'),
      ]
      expect(subject.le_flood_cert_fee_amount).to eq 300
    end
  end

  describe "total_cash_back" do
    it "should return nil if no matching records found" do
      loan.stub(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: "Credit Report", total_amt: 200)]}
      expect(subject.total_cash_back).to be_nil
    end

    it "should return amount if it matches" do
      loan.stub hud_lines: [
        build_stubbed(:hud_line, sys_fee_name: "Due from Borrower at Closing", total_amt: 301, hud_type: 'HUD'),
        build_stubbed(:hud_line, sys_fee_name: "Due from Borrower at Closing", total_amt: 300, hud_type: 'GFE'),
      ]
      expect(subject.total_cash_back).to eq 301
    end
  end

  describe "Loan Officer Name" do
    it "should return nil when no interviewer information available" do
      loan.stub interviewer: nil
      expect(subject.loan_officer_name).to be_nil
    end

    it "should return name when it is available" do
      loan.stub_chain(:interviewer, name: "Foo Bob")
      expect(subject.loan_officer_name).to eq "Foo Bob"
    end
  end

  describe "Days Since Application Received" do
    it "should return nil if application recieved date is not available" do
      loan.stub application_date: nil
      expect(subject.days_since_application_received).to be_nil
    end

    it "should return 0 if the application recieved date is today" do
      loan.stub application_date: Time.zone.today
      expect(subject.days_since_application_received).to eq 0
    end

    it "should not include weekends while calculating" do
      loan.stub application_date: Date.new(2015,8,27)
      Time.zone.stub today: Date.new(2015,9,2)
      expect(subject.days_since_application_received).to eq 4
    end
  end

  describe ".va_homebuyer_usage_indicator" do

    it "should be the manual fact type for VA Homebuyer Usage Indicator" do
      loan.stub manual_fact_types: [
        ManualFactType.new({name: "VA Homebuyer Usage Indicator", value: "Subsequent Usage"}, without_protection: true)
      ]
      expect(subject.va_homebuyer_usage_indicator).to eq "Subsequent Usage"
    end

    it "should handle non-va loan" do
      expect(subject.va_homebuyer_usage_indicator).to eq nil
    end

  end

  describe ".type_of_veteran" do

    it "should return the veteran type for a loan" do
      loan.stub manual_fact_types: [
        ManualFactType.new({name: "Type of Veteran", value: "Reserves"}, without_protection: true)
      ]
      expect(subject.type_of_veteran).to eq "Reserves"
    end

  end

  describe "existing_survey_indicator" do
    it "should be the value of the manual fact type named Existing Survey Indicator" do
      loan.stub manual_fact_types: [
        ManualFactType.new({name: "Existing Survey Indicator", value: "foo"}, without_protection: true)
      ]
      expect(subject.existing_survey_indicator).to eq "foo"
    end

    it "should be 'No' when there is no matching MFT" do
      loan.stub manual_fact_types: [
        ManualFactType.new({name: "fsljf", value: "foo"}, without_protection: true)
      ]
      expect(subject.existing_survey_indicator).to eq 'No'
    end
  end

  describe "Offering Identifier" do
    [["241", "Home Possible"],
    ["250", "Home Possible Advantage"],
    ["251", "Home Possible Advantage for HFAs"],
    ["310", "Relief Refinance - Open Access"],
    ["", nil]
      ].each do |val, expected|
        it "should return #{expected} when fre offering identifier is #{val}" do
          loan.stub_chain(:loan_feature, fre_offering_identifier: val)
          expect(subject.offering_identifier).to eq(expected)
        end
      end
  end
  describe ".call_flow_as_fact_type" do

    it "should return the conclusion of a failing flow" do
      flow_response = { :errors=>["Assets Doc Expiration Date must have a value.", "Credit Report Expiration Date must have a value.", "Income Doc Expiration Date must have a value.", "Title Doc Expiration Date must have a value."], 
                        :warnings=>[], 
                        :raw_response=>{
                            :flow_name=>"documents-expiration-dates-acceptance", 
                            :conclusion=>"Not Complete", 
                            :completed=>false, 
                            :stop_messages=>["Assets Doc Expiration Date must have a value.", "Credit Report Expiration Date must have a value.", "Income Doc Expiration Date must have a value.", "Title Doc Expiration Date must have a value."], 
                            :warning_messages=>[], 
                            :last_decision_view=>"DocumentsExpirationDatesAcceptanceDQComplete", 
                            :step_count=>4, 
                            :steps_executed_count=>1, 
                            :decision_flow=>[{"Determine Documents Expiration Dates Acceptance DQ Complete (Base)"=>"Not Complete"}], 
                            :meta_info=>{"system"=>"CtmdbWeb", "user"=>"UNKONWN", "context"=>"UNKNOWN", "initiation_point"=>"UNKNOWN", "environment"=>"development", "executed_at"=>"2015-09-08T15:23:52-04:00", "execution_time"=>0.24242377281188965}, 
                            :instance_fact_types=>{}, 
                            :uuid=>"104c2fb0-388d-0133-4dad-005056b81fc0"}, 
                        :conclusion=>"Not Complete"}
      fts = ["IncomeDocExpirationDate", "FloodInsuranceIndicator", "HomeownersInsuranceCondoMasterPolicyExpirationDate", "FiveBusinessDaysFromToday", "CreditReportExpirationDate", "FloodInsuranceExpirationDate", "HomeownersInsuranceExpirationDate", "AssetsDocExpirationDate", "AppraisalDocExpirationDate", "TitleDocExpirationDate", "CreditDocExpirationDate", "LoanProductName", "FloodInsuranceEffectiveDate", "HomeownersInsuranceEffectiveDate", "PurposeOfLoan", "TwoBusinessDaysFromToday", "FieldworkObtained", "SubmitToUnderwritingDate", "PurposeOfRefinance", "ClosingDate"]

      Ctmdecisionator::Flow.stub_chain("explain.fact_types.map").and_return(fts)
      Decisions::Flow.stub_chain("new.execute").and_return flow_response

      expect(subject.call_flow_as_fact_type('documents_expiration_dates_acceptance')).to eq "Not Complete"
    end

    it "should return the conclusion of a passing flow" do
      flow_response = { :errors=>[], 
                        :warnings=>[[81, "Please ensure the credit scores on the credit report match the credit scores on the underwriter conditions screen and the lock screen."]], 
                        :raw_response=>{
                            :flow_name=>"credit-score-comparison-acceptance", 
                            :conclusion=>"Acceptable", 
                            :completed=>true, 
                            :stop_messages=>[], 
                            :warning_messages=>["Please ensure the credit scores on the credit report match the credit scores on the underwriter conditions screen and the lock screen."], 
                            :last_decision_view=>"CreditScoreComparisonAcceptance", 
                            :step_count=>3, 
                            :steps_executed_count=>3, 
                            :decision_flow=>[{"Determine Credit Score Comparison Acceptance DQ Complete (Base)"=>"Complete"}, {"Determine Credit Score Comparison Acceptance DQ Domain Validity (Base)"=>"Valid"}, {"Determine Credit Score Comparison Acceptance (Base)"=>"Acceptable"}], 
                            :meta_info=>{"system"=>"CtmdbWeb", "user"=>"UNKONWN", "context"=>"UNKNOWN", "initiation_point"=>"UNKNOWN", "environment"=>"development", "executed_at"=>"2015-09-08T15:23:38-04:00", "execution_time"=>0.17149806022644043}, 
                            :instance_fact_types=>{}, 
                            :uuid=>"07e0dce0-388d-0133-4dab-005056b81fc0"},
                        :conclusion=>"Acceptable"}
      fts = ["RateLockStatus", "UWConditionsBorrowerCreditScore", "LockBorrowerCreditScore", "DownloadedBorrowerCreditScore", "DownloadedCoBorrowerCreditScore", "UWConditionsCoBorrowerCreditScore", "LockCoBorrowerCreditScore"]

      Ctmdecisionator::Flow.stub_chain("explain.fact_types.map").and_return(fts)
      Decisions::Flow.stub_chain("new.execute").and_return flow_response

      expect(subject.call_flow_as_fact_type('credit_score_comparison_acceptance')).to eq "Acceptable"
    end

    it "should handle errors" do
      fts = ["NonExistFactType"]

      Ctmdecisionator::Flow.stub_chain("explain.fact_types.map").and_return(fts)

      expect(subject.call_flow_as_fact_type(flow_name)).to eq nil
    end

  end

  describe "#get_flow_result for maximim closing date" do
    context "When the event id is being passed" do
      subject { Decisions::Facttype.new(flow_name, {loan: loan, event_id: 123}) }
      it "should look for the Loan Validation Event if the flow has already been executed and return conclusion" do
        flow = Bpm::LoanValidationFlow.new({name: "maximum_closing_date", conclusion: "Acceptable"}, without_protection: true)
        Bpm::LoanValidationEvent.stub_chain("find_by.loan_validation_flows.find_by").and_return(flow)
        expect(subject.maximum_closing_date).to eq("Acceptable")
      end

      it "should run the validation if it is not present in the validation events" do
        Bpm::LoanValidationEvent.stub_chain("find_by.loan_validation_flows.find_by").and_return(nil)
        subject.stub call_flow_as_fact_type: "Not Valid"
        expect(subject.maximum_closing_date).to eq("Not Valid")
      end
    end
  end

  describe ".webva_funding_fee_percentage" do

    it "should return the conclusion of WEB VA Percentage flow" do
      allow(subject).to receive(:call_flow_as_fact_type).with('va_funding_fee_amt').and_return "Acceptable"

      expect(subject.webva_funding_fee_percentage).to eq "Acceptable"
    end

  end

  describe "closing_request_submitted_plus10_business_date" do
    before do
      loan_general = FactoryGirl.build_stubbed(:loan_general)
      loan.stub(:loan_general) {loan_general}
    end

    it "should be the last event date for a closing request submitted event for the loan" do
      #this loan's last "Closing Request Submitted" event is 2011-11-03
      loan = Loan.find_by loan_num: 1020912
      ft = Decisions::Facttype.new(flow_name, {loan: loan})
      expect(ft.closing_request_submitted_plus10_business_date).to eq "11/12/2011"
    end

    it "should be nil if there are no Closing Request Submitted" do
      loan = Loan.find_by loan_num: 1012046
      ft = Decisions::Facttype.new(flow_name, {loan: loan})
      expect(ft.closing_request_submitted_plus10_business_date).to be_nil
    end

    describe "examples for closing_request_submitted_plus10_business_date" do
      let(:loan_event) { double("LoanEvent") }

      [ [ DateTime.new(2015,10,4), "10/15/2015"],
        [ DateTime.new(2015,10,19), "10/28/2015"],
        [ DateTime.new(2015,10,17), "10/28/2015"]
      ].each do |closing_date, expected_date|
        it "should return #{expected_date}, when closing date is #{closing_date}" do
          allow(loan_event).to receive(:closing_request_submitted_events).and_return([double("LoanEvent")])
          allow(loan).to receive(:loan_general).and_return(loan_general)
          allow(loan.loan_general).to receive(:loan_events).and_return(loan_event)

          allow(loan.loan_general.loan_events.closing_request_submitted_events).to receive(:order).with('event_date').and_return([double("LoanEvent", event_date: closing_date)])

          expect(subject.closing_request_submitted_plus10_business_date).to eq expected_date
        end
      end
    end

    it "should return saturday also as business day" do
      
      loan_event = double("LoanEvent")
      
      allow(loan_event).to receive(:closing_request_submitted_events).and_return([double("LoanEvent")])
      allow(loan).to receive(:loan_general).and_return(loan_general)
      allow(loan.loan_general).to receive(:loan_events).and_return(loan_event)

      allow(loan.loan_general.loan_events.closing_request_submitted_events).to receive(:order).with('event_date').and_return([double("LoanEvent", event_date: Date.new(2015,5,7)), double("LoanEvent", event_date: Date.new(2015,10,7))])

      expect(subject.closing_request_submitted_plus10_business_date).to eq("10/17/2015")
    end
  end

  describe "Initial LE Sent plus 10 Date" do
    before {loan.stub loan_general: FactoryGirl.build_stubbed(:loan_general)}
    it "should return nil when there is no value " do
      subject.stub initial_le_sent_date: nil
      expect(subject.initial_le_sent_plus10_date).to be_nil
    end

    it "should return initial_le_sent_date + 10 days when date is available" do
      subject.stub initial_le_sent_date: "09/11/2015"
      expect(subject.initial_le_sent_plus10_date).to eq("09/25/2015")
    end
  end

  describe ".state_housing_underwriting_fee" do
    before {loan.stub loan_general: FactoryGirl.build_stubbed(:loan_general)}
    context "when loan is TRID or pre TRID loan" do
      it "should return nil when the product code is not available or does not match" do
        expect(subject.state_housing_underwriting_fee).to be_nil
      
        loan.loan_general.stub_chain(:underwriting_datum, product_code: "FHA30")
        expect(subject.state_housing_underwriting_fee).to be_nil

        loan.loan_general.stub_chain(:lock_price, product_code: "C30FXD")
        expect(subject.state_housing_underwriting_fee).to be_nil
      end

      it "should return the Hud_lines underwriting fee total amount if the product code matches" do
        loan.loan_general.stub_chain(:underwriting_datum, product_code: "FHA30 IHDA IL SM")
        loan.stub hud_lines: [ 
          build_stubbed(:hud_line, sys_fee_name: "Underwriting Fee", total_amt: 101, hud_type: 'HUD'),
          build_stubbed(:hud_line, sys_fee_name: "Underwriting Fee", total_amt: 100, hud_type: 'GFE'),
        ]
        expect(subject.state_housing_underwriting_fee).to eq 100
      end
    end

    ["FHA 30 IHCDA IN", "FHA30 IHCDA IN NH", "FHA30 IHDA IL SM", 
      "FHA30 MSHDA", "MSHDA DPA", "C30FXD IHDA IL", "C30FXD IHDA IL FH", 
      "FHA30 IHDA IL FH", "MSHDA NH", 'FHA30 GA Dream', 'FHA30 GA CHOICE',
      'FHA30 GA PEN', 'C30FXD KY HC', 'FHA30 KY HC', 'FHA15STR'].each do |value|
        it "should return the total amount with matching system fee name when the product code is #{value}" do
          loan.loan_general.stub underwriting_datum: nil
          loan.stub hud_lines: [ 
            build_stubbed(:hud_line, sys_fee_name: "Underwriting Fee", total_amt: 101, hud_type: 'HUD'),
            build_stubbed(:hud_line, sys_fee_name: "Underwriting Fee", total_amt: 400, hud_type: 'GFE'),
          ]
          loan.loan_general.stub_chain(:loan_feature, product_name: value)
          expect(subject.state_housing_underwriting_fee).to eq 400
        end 
    end
  end

  describe ".state_housing_origination_fee" do
    before {loan.stub loan_general: FactoryGirl.build_stubbed(:loan_general)}
    context "when loan is TRID / pre TRID loan" do
      it "should return nil when product code is not present or do not match the expected ones" do
        expect(subject.state_housing_origination_fee).to be_nil

        loan.loan_general.stub_chain(:loan_feature, product_name: "FH")
        expect(subject.state_housing_origination_fee).to be_nil

        loan.loan_general.stub_chain(:lock_price, product_code: "C30FXD")
        expect(subject.state_housing_origination_fee).to be_nil
      end

      it "should return the hud_lines total amount if the System fee name is State Housing Origination Fee" do
        loan.loan_general.stub_chain(:underwriting_datum, product_code: "MSHDA DPA")
        loan.stub hud_lines: [ 
          build_stubbed(:hud_line, sys_fee_name: "Underwriting Fee", total_amt: 200), 
          build_stubbed(:hud_line, sys_fee_name: "Origination Fee", total_amt: 301, hud_type: 'HUD'),
          build_stubbed(:hud_line, sys_fee_name: "Origination Fee", total_amt: 300, hud_type: 'GFE'),
        ]
        expect(subject.state_housing_origination_fee).to eq 300
      end
    end

    ["FHA 30 IHCDA IN", "FHA30 IHCDA IN NH", "FHA30 IHDA IL SM", 
    "FHA30 MSHDA", "MSHDA DPA", "C30FXD IHDA IL", "C30FXD IHDA IL FH", 
    "FHA30 IHDA IL FH", "MSHDA NH", 'FHA30 GA Dream', 'FHA30 GA CHOICE',
    'FHA30 GA PEN', 'C30FXD KY HC', 'FHA30 KY HC', 'FHA15STR'].each do |value|
      it "should return the total amount with matching system fee name when the product code is #{value}" do
        loan.loan_general.stub underwriting_datum: nil
        loan.stub hud_lines: [ 
          build_stubbed(:hud_line, sys_fee_name: "Origination Fee", total_amt: 101, hud_type: 'HUD'),
          build_stubbed(:hud_line, sys_fee_name: "Origination Fee", total_amt: 300, hud_type: 'GFE'),
        ]
        loan.loan_general.stub_chain(:loan_feature, product_name: value)
        expect(subject.state_housing_origination_fee).to eq 300
      end 
    end
  end

  describe ".state_housing_funding_fee" do
    before { loan.stub loan_general: loan_general }
    it "should return nil when product code is not present" do
      expect(subject.state_housing_funding_fee).to be_nil
    end

    it "should return nil when the product code does not match" do
      loan.loan_general.stub_chain(:loan_feature, product_name: "MSHDA")
      expect(subject.state_housing_funding_fee).to be_nil

      loan.loan_general.stub_chain(:lock_price, product_code: "IHCDA")
      expect(subject.state_housing_funding_fee).to be_nil
    end

    ["FHA 30 IHCDA IN", "FHA30 IHCDA IN NH", "FHA30 IHDA IL SM", 
    "FHA30 MSHDA", "MSHDA DPA", "C30FXD IHDA IL", "C30FXD IHDA IL FH", 
    "FHA30 IHDA IL FH", "MSHDA NH", 'FHA30 GA Dream', 'FHA30 GA CHOICE',
    'FHA30 GA PEN', 'C30FXD KY HC', 'FHA30 KY HC', 'FHA15STR'].each do |value|
      it "should return the total amount system fee name % Funding Fee and product code #{value}" do
        loan.loan_general.stub underwriting_datum: nil
        loan.stub hud_lines: [ 
          build_stubbed(:hud_line, sys_fee_name: "State Housing Funding Fee", total_amt: 101, hud_type: 'HUD'),
          build_stubbed(:hud_line, sys_fee_name: "Foo Funding Fee", total_amt: BigDecimal.new('1234.35678978'), hud_type: 'GFE'),
        ]
        loan.loan_general.stub_chain(:loan_feature, product_name: value)
        expect(subject.state_housing_funding_fee).to eq 1234.36
      end 
    end

  end

  describe ".downpayment_percentage" do

    context "Refinance" do
      before { allow(loan).to receive(:loan_type).and_return('Refinance') }

      it "should return a decimal value" do
        allow(loan).to receive(:ltv).and_return(41.65)

        expect(subject.downpayment_percentage).to eq 58.35
      end

      it "should handle nil source data" do
        allow(loan).to receive(:ltv).and_return nil

        expect(subject.downpayment_percentage).to be_nil
      end
    end

    context "Not Refinance" do
      before { allow(loan).to receive(:loan_type).and_return('Purchase') }

      it "returns the proper amount" do
        allow(loan).to receive(:purchase_price_amount).and_return(BigDecimal.new("150000"))
        allow(loan).to receive_message_chain(:mortgage_term, :base_loan_amount) { BigDecimal.new("100000") }
        
        expect(subject.downpayment_percentage).to eq 33.33
      end

      it "should return 0 if property_purchase_price is 0" do
        loan.stub purchase_price_amount: 0
        loan.stub_chain(:mortgage_term, base_loan_amount: 12)
        expect(subject.downpayment_percentage).to eq 0
      end

      it "should return 0 when base amount is 0" do
        loan.stub_chain(:mortgage_term, base_loan_amount: nil)
        expect(subject.downpayment_percentage).to eq 0
      end

      it "should return 9.28 for this example" do
        loan.stub purchase_price_amount: 995_000
        loan.stub_chain(:mortgage_term, base_loan_amount: 902_625)
        expect(subject.downpayment_percentage).to eq 9.28
      end
    end

  end

  describe ".cd_delivery_method" do
    before {loan.stub loan_general: FactoryGirl.build_stubbed(:loan_general)}
    it "should retutn nil when the method_type unavailable" do
      loan.loan_general.stub_chain(:loan_detail, cd_disclosure_method_type: nil)
      expect(subject.cd_delivery_method).to be_nil
    end

    [ ['ElectronicDisclosure', 'Email'],
    ['FaceToFace', 'In Person'],
    ['Mail', 'US Mail'],
    ['Other', 'Other']
      ].each do |del_method, expected|
        it "should return #{expected} when cd_disclosure_method_type is #{del_method} " do
          loan.loan_general.stub_chain(:loan_detail, cd_disclosure_method_type: del_method)
          expect(subject.cd_delivery_method).to eq expected
        end
      end
  end

  describe ".initial_cd_delivery_plus_six_date" do
    before {loan.stub loan_general: FactoryGirl.build_stubbed(:loan_general)}
    it "should return nil when the cd _disclosure_date is nil" do
      loan.loan_general.stub_chain(:loan_detail, cd_disclosure_date: nil)
      expect(subject.initial_cd_delivery_plus_six_date).to be_nil
    end

    it "should return date after adding 6 days to the date" do
      loan.loan_general.stub_chain(:loan_detail, cd_disclosure_date: Date.new(2015,9,16))
      expect(subject.initial_cd_delivery_plus_six_date).to eq("09/23/2015")

      loan.loan_general.stub_chain(:loan_detail, cd_disclosure_date: Date.new(2015,9,1))
      expect(subject.initial_cd_delivery_plus_six_date).to eq("09/09/2015")
    end
  end

  describe ".redisclosure_cd_delivery_date" do

    before {loan.stub loan_general: FactoryGirl.build_stubbed(:loan_general)}

    it "should return the rediscosure date if set" do
      ret_date = 5.minutes.ago
      loan.loan_general.stub_chain(:loan_detail, cd_redisclosure_date: ret_date)
      loan.loan_general.stub_chain(:loan_detail, cd_disclosure_date: 2.days.ago)

      expect(subject.redisclosure_cd_delivery_date).to eq ret_date
    end

    it "should return the disclosure date if redisclosure not set" do
      ret_date = 2.days.ago
      loan.loan_general.stub_chain(:loan_detail, cd_redisclosure_date: nil)
      loan.loan_general.stub_chain(:loan_detail, cd_disclosure_date: ret_date)

      expect(subject.redisclosure_cd_delivery_date).to eq ret_date
    end

    it "should handle having neither date set" do
      loan.loan_general.stub_chain(:loan_detail, cd_redisclosure_date: nil)
      loan.loan_general.stub_chain(:loan_detail, cd_disclosure_date: nil)

      expect(subject.redisclosure_cd_delivery_date).to be_nil
    end

  end

  describe "is_veteran_exempt" do
    it "should be nil when there is no va_loan" do
      loan.stub va_loan: nil
      expect(subject.is_veteran_exempt).to be nil
    end

    it "should be nil when funding_fee_exempt_indicator is not set" do
      loan.stub_chain(:va_loan, :funding_fee_exempt_indicator).and_return(nil)
      expect(subject.is_veteran_exempt).to be nil
    end

    it "should be Yes when funding_fee_exempt_indicator is true" do
      loan.stub_chain(:va_loan, :funding_fee_exempt_indicator).and_return(true)
      expect(subject.is_veteran_exempt).to eq "Yes"
    end

    it "should be No when funding_fee_exempt_indicator is false" do
      loan.stub_chain(:va_loan, :funding_fee_exempt_indicator).and_return(false)
      expect(subject.is_veteran_exempt).to eq "No"
    end
  end

  describe "closing_cannot_occur_until_date" do
    it "should come from gfe_detail earliest_closing_date_after_initial_gfe_disclosure" do
      loan.stub_chain(:loan_general, :gfe_detail, :earliest_closing_date_after_initial_gfe_disclosure).and_return DateTime.new(2015, 1, 31, 12, 35, 56)
      expect(subject.closing_cannot_occur_until_date).to eq "01/31/2015"
    end

    it "should come instead from earliest_closing_date_after_gfe_redisclosure if that has a value too" do
      loan.stub_chain(:loan_general, :gfe_detail, :earliest_closing_date_after_initial_gfe_disclosure).and_return DateTime.new(2015,3, 31)
      loan.stub_chain(:loan_general, :gfe_detail, :earliest_closing_date_after_gfe_redisclosure).and_return DateTime.new(2015, 1, 31)
      expect(subject.closing_cannot_occur_until_date).to eq "01/31/2015"
    end
  end

  describe "cd_proof_of_receipt_date" do
    before {loan.stub loan_general: FactoryGirl.build_stubbed(:loan_general)}
    it "should be nil when there is no cd_borrower_received_disclosure value for loan_detail" do
      loan.loan_general.stub_chain(:loan_detail, cd_borrower_received_disclosure: nil)
      expect(subject.cd_proof_of_receipt_date).to be_nil
    end

    it "should return date from cd_borrower_received_disclosure if present" do
      loan.loan_general.stub_chain(:loan_detail, cd_borrower_received_disclosure: Date.new(2015,1,1))
      expect(subject.cd_proof_of_receipt_date).to eq "01/01/2015"
    end
  end

  describe "box_a_discount_percentage" do
    it "should return the proper value when discount points is > 0" do
      loan.stub_chain(:hud_lines, :gfe, :by_fee_name).and_return [OpenStruct.new({total_amt: 100})]
      loan.stub_chain(:loan_general,:gfe_loan_datum,:original_loan_amount).and_return(200)
      expect(subject.box_a_discount_percentage).to eq(50)
    end

    it "should round to 3 decimals" do
      loan.stub_chain(:hud_lines, :gfe, :by_fee_name).and_return [OpenStruct.new({total_amt: 106})]
      loan.stub_chain(:loan_general,:gfe_loan_datum,:original_loan_amount).and_return(200_003)
      expect(subject.box_a_discount_percentage).to eq(0.053)
    end

    it "should return nil if the discount price is == 0" do
      loan.stub_chain(:hud_lines, :gfe, :by_fee_name).and_return [OpenStruct.new({total_amt: 0})]
      expect(subject.box_a_discount_percentage).to eq(nil)
    end

    it "should return nil if there is no discount points on the loan" do
      loan.stub_chain(:hud_lines, :gfe, :by_fee_name).and_return nil
      expect(subject.box_a_discount_percentage).to eq(nil)
    end
  end

  describe "is_this_acema" do
    before { loan.stub_chain(:account_info, channel: "Disclosure Request") }
    it "should return nil when there are no matching custom fields" do
      loan.stub_chain(:custom_fields) {[build_stubbed(:custom_field)]}
      expect(subject.is_this_acema).to be_nil
    end

    describe "when channel is W0-Wholesale Standard" do
      before { loan.stub_chain(:account_info, channel: "W0-Wholesale Standard") }
      it "should return Yes when the attribute value is Y for Wholesale Disclosure Request and Attribute unique name NY CEMA" do
        loan.stub_chain(:custom_fields) {[build_stubbed(:custom_field, form_unique_name: "Wholesale Initial Disclosure Request", attribute_unique_name: "NY CEMA", attribute_value: "Y")]}
        expect(subject.is_this_acema).to eq "Yes"
      end

      it "should return nil when there are no matching entries" do
        loan.stub_chain(:custom_fields) {[build_stubbed(:custom_field, form_unique_name: "Wholesale Initial Disclosure Request", attribute_unique_name: "NYCEMA", attribute_value: "Y")]}
        expect(subject.is_this_acema).to be_nil
      end
    end
    it "should return No when the attribute value is N for Disclosure request and Attribute unique name NY CEMA" do
      loan.stub_chain(:custom_fields) {[build_stubbed(:custom_field, form_unique_name: "Retail Initial Disclosure Request", attribute_unique_name: "NYCEMA", attribute_value: "N")]}
      expect(subject.is_this_acema).to eq "No"
    end

    it "should return N/A when the attribute value is NA" do
      loan.stub_chain(:custom_fields) {[build_stubbed(:custom_field, form_unique_name: "Retail Initial Disclosure Request", attribute_unique_name: "NYCEMA", attribute_value: "NA")]}
      expect(subject.is_this_acema).to eq "N/A"
    end
  end

  describe "closer_cd_flag" do
    let(:master_loan) {Master::Loan}
    let(:new_master_loan) { Master::Loan.new(id: 123)}
    let(:custom_loan_date) {Master::LoanDetails::CustomLoanData.new}
    
    it "should return No when there is no entry for the CD disclosed by" do
      new_master_loan.stub_chain(:custom_loan_data, loan_num: 123)
      allow(master_loan).to receive(:find_by).with(loan_num: nil).and_return(new_master_loan)
      expect(subject.closer_cd_flag).to eq("No")
    end

    it "should return Yes when the loan is Disclosed by CD" do
      new_master_loan.stub_chain(:custom_loan_data) { build_stubbed(:custom_loan_data, loan_num: 123, disclose_by_cd_user_uuid: "FFDDEE")}
      allow(master_loan).to receive(:find_by).with(loan_num: nil).and_return(new_master_loan)
      expect(subject.closer_cd_flag).to eq("Yes")
    end
  end

  describe "mi_coverage_percentage" do
    
    it "should be nil when there is no mi coverage percentage" do
      loan.stub proposed_housing_expenses: []
      expect(subject.mi_coverage_percentage).to be_nil
    end

    it "should ignore the value from Lock loan data when no proposed housing expense value" do
      loan.stub proposed_housing_expenses: []
      loan.stub_chain(:lock_loan_datum, mi_coverage_percentage: BigDecimal.new('23.5'))
      expect(subject.mi_coverage_percentage).to eq nil
    end

    it "should ignore the value from Lock loan data when proposed housing expense value exists" do
      loan.stub proposed_housing_expenses: [
        OpenStruct.new({housing_expense_type: "MI", mi_coverage_percent: 42})
      ]

      loan.stub_chain(:lock_loan_datum, mi_coverage_percentage: BigDecimal.new('23.5'))
      expect(subject.mi_coverage_percentage).to eq 42
    end

    it "should only use the value of proposed housing expense of type MI" do
      loan.stub proposed_housing_expenses: [
        OpenStruct.new({housing_expense_type: "RealEstateTax", mi_coverage_percent: 43}), #wouldn't really have a mi_coverage_percent value
        OpenStruct.new({housing_expense_type: "MI", mi_coverage_percent: 25})
      ]

      expect(subject.mi_coverage_percentage).to eq 25
    end

    it "should return the value from proposed housing expense when it exists" do
      loan.stub proposed_housing_expenses: [
        OpenStruct.new({housing_expense_type: "MI", mi_coverage_percent: 30})
      ]
      expect(subject.mi_coverage_percentage).to eq 30
    end
  end

  describe "line902_paid_by_type" do
    it "should be nil if no matching hud line" do
      loan.stub hud_lines: []
      expect(subject.line902_paid_by_type).to be nil
    end

    it "should be paid_by from the first matching hud line" do
      loan.stub hud_lines: [ 
        build_stubbed(:hud_line, line_num: 902, hud_type: 'HUD', paid_by: 'a'),
        build_stubbed(:hud_line, line_num: 903, hud_type: 'GFE', paid_by: 'b'),
        build_stubbed(:hud_line, line_num: 902, hud_type: 'GFE', paid_by: 'c'),
      ]
      expect(subject.line902_paid_by_type).to eq 'c'
    end
  end

  describe ".right_to_delay_indicator" do
    it "should return Yes when there is manual facttype entered for right to delay" do
      fact_types = ManualFactType.new(name: 'foo', value: '123')
      allow(loan).to receive(:collect_facttype).with('right_to_delay').and_return(fact_types)
      expect(subject.right_to_delay_indicator).to eq "Yes"
    end

    it "should return No when there are no manually entered fact type for it" do
      allow(loan).to receive(:collect_facttype).with('right_to_delay').and_return(nil)
      expect(subject.right_to_delay_indicator).to eq "No"
    end
  end

  describe ".texas50_a6_indicator" do
    let(:fact_type) { FactoryGirl.build_stubbed(:manual_fact_type)}
    [ ['No', 'Not 50A6'],
      ['Yes', '50A6']
    ].each do |value, expected| 
      it "should retuen #{expected} when the manually enetered value is #{value}" do
        fact_type.stub value: value
        allow(loan).to receive(:collect_facttype).with('texas_only').and_return(fact_type)
        expect(subject.texas50_a6_indicator).to eq expected
      end
    end

    context "When there is no manually entered value" do
      before do
        allow(loan).to receive(:collect_facttype).with('texas_only').and_return(nil)
      end

      { "Yes" => "50A6",
        "No" => "Not 50A6",
        "NA" => "NA",
        "No Entry" => "NA",
        "fldsjf" => "NA",
      }.each do |broker_value, answer|
        it "should return #{answer} when the broker entered value is #{broker_value}" do
          loan.stub is_texas_50A6: broker_value
          expect(subject.texas50_a6_indicator).to eq answer
        end
      end
    end
  end

  describe "USDA Conditional Commitment Date" do
    it "should be nil if there is no loan_feature date" do
      loan.stub_chain(:loan_feature, :c_commitment_date).and_return nil
      expect(subject.usda_conditional_commitment_date).to eq nil
    end

    it "should format the date from loan_feature when present" do
      loan.stub_chain(:loan_feature, :c_commitment_date).and_return DateTime.new(2015, 9, 25, 12, 45, 31)
      expect(subject.usda_conditional_commitment_date).to eq "09/25/2015"
    end
  end

  describe "e_consent_indicator" do
    it "should be the value of the manual fact type if it exists" do
      loan.stub manual_fact_types: [
        ManualFactType.new({name: "E Consent Indicator", value: "foo"}, without_protection: true)
      ]
      expect(subject.e_consent_indicator).to eq 'foo'
    end

    it "shoudl be nil if there is no such mft" do
      loan.stub manual_fact_types: []
      expect(subject.e_consent_indicator).to be nil
    end
  end

  describe "monthly_guarantee_fee_percentage" do
    it "should be nil if there is no PHE with mortgage insurance" do
      stub(:proposed_monthly_mortgage_insurance_payment) {nil}
      expect(subject.monthly_guarantee_fee_percentage).to be nil
    end

    it "should be some fraction of the loan amt if there is a PHE with MI" do
      loan = Loan.find_by loan_num: 1022358
      subject = Decisions::Facttype.new(flow_name, {loan: loan})
      
      # ((monthly insurance * 12) / base_loan_amount) * 100 -> monthly insurance = 49.33, base loan amount = 242250
      expect(subject.monthly_guarantee_fee_percentage).to eq (((49.33 * 12) / 242250.0) * 100.0).round(2)
    end
  end

  describe "mi_certification_number" do
    it "should be nil if no mi_datum" do
      loan.stub mi_datum: nil
      expect(subject.mi_certification_number).to be nil
    end

    it "should be the mi_datum cert no" do
      loan.stub_chain(:mi_datum, :mi_certificate_identifier).and_return 'foo'
      expect(subject.mi_certification_number).to eq 'foo'
    end
  end

  describe "va_funding_fee_percentage" do
    it "should be nil if there is no matching hud line" do
      loan.stub hud_lines: []
      expect(subject.va_funding_fee_percentage).to eq nil
    end

    it "for pre trid loan it should return the rate percentage" do
      loan.stub trid_loan?: false
      loan.stub hud_lines: [
        build_stubbed(:hud_line, sys_fee_name: 'VA funding fee', hud_type: 'GFE', rate_perc: BigDecimal.new("23.45")),
        build_stubbed(:hud_line, sys_fee_name: 'Federal VA Funding Fee', hud_type: 'GFE', rate_perc: BigDecimal.new("12"), total_amt: BigDecimal.new('23'))
      ]
      expect(subject.va_funding_fee_percentage).to eq 23.45
    end

    it "should divide the matching hud amount by base loan amt and return as a pct" do
      loan.stub trid_loan?: true
      loan.stub hud_lines: [
        build_stubbed(:hud_line, sys_fee_name: "Federal VA Funding Fee", hud_type: "GFE", total_amt: "1000"),
        build_stubbed(:hud_line, sys_fee_name: "Federal VA Funding Fee", hud_type: "HUD", total_amt: "1001"),
        build_stubbed(:hud_line, sys_fee_name: "sofjds", hud_type: "GFE", total_amt: "1002"),
      ]
      loan.stub_chain(:mortgage_term, :base_loan_amount).and_return 208_000
      expect(subject.va_funding_fee_percentage).to eq 0.48
    end
  end

  describe ".loan_product_name" do
    before do
      loan.stub loan_general: FactoryGirl.build_stubbed(:loan_general) 
      loan.loan_general.stub underwriting_datum: nil
      loan.loan_general.stub loan_feature: nil
      loan.loan_general.stub lock_price: nil
      loan.loan_general.stub gfe_loan_datum: nil
    end
    it "should return translated value for 'VA 15yr Fixed'" do
      loan.loan_general.stub_chain(:underwriting_datum) {build_stubbed(:underwriting_datum, product_code: 'VA 15yr Fixed')}
      expect(subject.loan_product_name).to eq "VA15FXD"
    end

    it "should return from lock price if all other have no value" do
      loan.loan_general.stub_chain(:lock_price) {build_stubbed(:lock_price, product_code: 'FHA30 IHDA IL FH')}
      expect(subject.loan_product_name).to eq "FHA30 IHDA IL FH"
    end

    it "should return the value from gfe_loan_datum.loan_program when none of the hugher priority matches" do
      loan.loan_general.stub_chain(:gfe_loan_datum) {build_stubbed(:gfe_loan_datum, loan_program: 'Conforming 20yr Fixed')}
      expect(subject.loan_product_name).to eq('C20FXD')
    end

    it "should return nil when none of the product code matches" do
      expect(subject.loan_product_name).to be_nil
    end

    ['C15FXD HR', 'C20FXD HR', 'C30FXD HR','C5/1ARM LIB HR', 'C7/1ARM LIB HR','C10/1ARM LIB HR'].each do |loan_product|
      it "should return #{loan_product} when product code is #{loan_product}" do
        loan.loan_general.stub_chain(:lock_price) { build_stubbed(:lock_price, product_code: loan_product) }
        expect(subject.loan_product_name).to eq loan_product
      end
    end
  end

  describe "mi_program" do
    { "" => nil,
      '1' => "Lender Paid",
      '2' => "Monthly Premium",
      '3' => "Risked Based Single Premium",
      '4' => "Single Premium",
      '5' => "Split Premium",
      '6' => "A Minus",
    }.each do |code, result|
      it "should translate '#{code}' to '#{result}'" do
        loan.stub_chain(:mi_datum, :mi_program_1003).and_return code
        expect(subject.mi_program).to eq result
      end
    end

    it "should return nil when there is no entry for mi_program_1003" do
      loan.stub mi_datum: nil
      expect(subject.mi_program).to be_nil
    end
  end

  describe "rate_lock_request_lender_paid_mi" do
    it "should return nil when the lender_paid_mi is nil" do
      loan.stub_chain(:lock_loan_datum, lender_paid_mi: nil)
      expect(subject.rate_lock_request_lender_paid_mi).to be_nil
    end

    it "should return Yes when lender_paid_mi is true " do
      loan.stub_chain(:lock_loan_datum, lender_paid_mi: true)
      expect(subject.rate_lock_request_lender_paid_mi).to eq 'Yes'
    end

    it "should return No when the indicator is false" do
      loan.stub_chain(:lock_loan_datum, lender_paid_mi: false)
      expect(subject.rate_lock_request_lender_paid_mi).to eq 'No'
    end
  end

  describe "rate_lock_request_mi_required" do
    it "should return nil when the mi_indicator is nil" do
      loan.stub_chain(:lock_loan_datum, mi_indicator: nil)
      expect(subject.rate_lock_request_mi_required).to be_nil
    end

    it "should return Yes when mi_indicator is true " do
      loan.stub_chain(:lock_loan_datum, mi_indicator: true)
      expect(subject.rate_lock_request_mi_required).to eq 'Yes'
    end

    it "should return No when the indicator is false" do
      loan.stub_chain(:lock_loan_datum, mi_indicator: false)
      expect(subject.rate_lock_request_mi_required).to eq 'No'
    end
  end

  describe "lock_net_price_amount" do
    it "should return nil if lock_price net_price is nil" do
      loan.stub_chain(:lock_price, net_price: nil)
      expect(subject.lock_net_price_amount).to eq 0
    end

    context "net price is > 100" do
      it "should return amount if lock_price net_price is populated" do
        loan.stub_chain(:lock_price, net_price: 101.25)
        loan.stub_chain(:lock_loan_datum, total_loan_amt: 100_000)
        expect(subject.lock_net_price_amount).to eq 1250
      end

      it "should return amount if lock_price net_price is populated" do
        loan.stub_chain(:lock_price, net_price: 101.25)
        loan.stub_chain(:lock_loan_datum, total_loan_amt: 97_123)
        expect(subject.lock_net_price_amount).to eq 1214.04
      end
    end

    context "net price is < 100" do
      it "should return amount if lock_price net_price is populated" do
        loan.stub_chain(:lock_price, net_price: 99.25)
        loan.stub_chain(:lock_loan_datum, total_loan_amt: 100_000)
        expect(subject.lock_net_price_amount).to eq 0.75
      end

      it "should return amount if lock_price net_price is populated" do
        loan.stub_chain(:lock_price, net_price: 66)
        loan.stub_chain(:lock_loan_datum, total_loan_amt: nil)
        expect(subject.lock_net_price_amount).to eq 34.0
      end
    end

    it "should return 0 when net price is 100" do
      loan.stub_chain(:lock_price, net_price: nil)
      expect(subject.lock_net_price_amount).to eq 0
    end
  end

  describe ".va_funding_fee_amount" do
    context "when loan is not a TRID loan" do
      before { loan.stub trid_loan?: false }
      it "should return nil when mortgage_type is not VA" do
        loan.stub_chain(:mortgage_term, mortgage_type: "FHA")
        expect(subject.va_funding_fee_amount).to be_nil
      end
      describe "should return funding fee total amout when mortgage type is VA" do
        before { loan.stub_chain(:mortgage_term, mortgage_type: "VA") }
        it "should return mi funding fee total amount" do
          loan.stub_chain(:transaction_detail, mi_and_funding_fee_total_amount: BigDecimal.new("23.45"))
          expect(subject.va_funding_fee_amount).to eq(23.45)
        end
        it "should return nil when no mi funding fee total amount" do
          loan.stub transaction_detail: FactoryGirl.build_stubbed(:transaction_detail)
          expect(subject.va_funding_fee_amount).to be_nil
        end
      end
    end

    context "when loan is a TRID loan" do
      before { loan.stub trid_loan?: true }
      it "should return nil when no hud lines matching" do
        allow(loan).to receive(:hud_lines).and_return([])
        expect(subject.va_funding_fee_amount).to be_nil
      end
      it "should return total amout when system fee name matches" do
        loan.stub hud_lines: [
          build_stubbed(:hud_line, sys_fee_name: 'VA funding fee', hud_type: 'GFE', total_amt: BigDecimal.new("23.45")),
          build_stubbed(:hud_line, sys_fee_name: 'Federal VA Funding Fee', hud_type: 'GFE', total_amt: BigDecimal.new('23'))
        ]
        expect(subject.va_funding_fee_amount).to eq 23
      end
    end
  end

  describe ".closing_date" do
    it "should return nil when no date is available" do
      loan.stub loan_feature: nil
      expect(subject.closing_date).to be_nil
    end

    it "should return value stored in loan_scheduled_closing_date" do
      loan.stub_chain(:loan_feature, loan_scheduled_closing_date: DateTime.new(2015,2,3))
      expect(subject.closing_date).to eq("02/03/2015")
    end

    it "shoudl return the date stored in requested_closing_date if no value in loan_scheduled_closing_date" do
      loan.stub_chain(:loan_feature, loan_scheduled_closing_date: nil)
      loan.stub_chain(:loan_feature, requested_closing_date: DateTime.new(2015,6,7))
      expect(subject.closing_date).to eq("06/07/2015")
    end
  end

  describe ".line_n_amount" do
    it "should return nil when data is missing" do
      expect(subject.line_n_amount).to be_nil
    end

    it "should return the value stored for MIAndFundingFeeFinancedAmount" do
      loan.stub_chain(:transaction_detail, mi_and_funding_fee_financed_amount: BigDecimal.new("23.45"))
      expect(subject.line_n_amount).to eq 23.45
    end

    it "should round the value for MIAndFundingFeeFinancedAmount" do
      loan.stub_chain(:transaction_detail, mi_and_funding_fee_financed_amount: BigDecimal.new("56.4567"))
      expect(subject.line_n_amount).to eq 56.46
    end
  end

  describe '.total_escrow_months' do

    it 'should add all months' do
      loan.stub hud_lines: [
        build_stubbed(:hud_line, fee_category: 'InitialEscrowPaymentAtClosing', hud_type: 'GFE', num_months: 2),
        build_stubbed(:hud_line, fee_category: 'InitialEscrowPaymentAtClosing', hud_type: 'GFE', num_months: 4)
      ]
      expect(subject.total_escrow_months).to eq 6
    end

    it 'should only read from GFE' do
      loan.stub hud_lines: [
        build_stubbed(:hud_line, fee_category: 'InitialEscrowPaymentAtClosing', hud_type: 'HUD', num_months: 2),
        build_stubbed(:hud_line, fee_category: 'InitialEscrowPaymentAtClosing', hud_type: 'GFE', num_months: 4)
      ]
      expect(subject.total_escrow_months).to eq 4
    end

    it 'should only read from correct fee category' do
      loan.stub hud_lines: [
        build_stubbed(:hud_line, fee_category: 'InitialEscrowPaymentAtClosing', hud_type: 'GFE', num_months: 2),
        build_stubbed(:hud_line, fee_category: 'FooBar', hud_type: 'GFE', num_months: 4)
      ]
      expect(subject.total_escrow_months).to eq 2
    end

    it 'should return 0 if no data found' do
      loan.stub hud_lines: [
        build_stubbed(:hud_line, fee_category: 'Foo', hud_type: 'HUD', num_months: 2),
        build_stubbed(:hud_line, fee_category: 'Bar', hud_type: 'HUD', num_months: 4)
      ]
      expect(subject.total_escrow_months).to eq 0
    end

  end

  describe ".line_g_amount" do
    it "should return nil when data is missing" do
      expect(subject.line_g_amount).to be_nil
    end

    it "should return the value stored for MIAndFundingFeeTotalAmount" do
      loan.stub_chain(:transaction_detail, mi_and_funding_fee_total_amount: BigDecimal.new("99.12"))
      expect(subject.line_g_amount).to eq 99.12
    end

    it "should round the value for MIAndFundingFeeTotalAmount" do
      loan.stub_chain(:transaction_detail, mi_and_funding_fee_total_amount: BigDecimal.new("12.3456"))
      expect(subject.line_g_amount).to eq 12.35
    end
  end

  describe ".total_poc" do

    ['FHA 30 IHCDA IN', 'FHA30 IHCDA IN NH', 'FHA30 IHDA IL SM', 'FHA30 MSHDA', 'MSHDA DPA',
      'C30FXD IHDA IL', 'C30FXD IHDA IL FH', 'FHA30 IHDA IL FH', 'MSHDA NH'].each do |code|
      it "should add credits for loans with product code #{code}" do
        loan.stub(product_code: "#{code}")
        loan.stub purchase_credits: [
          build_stubbed(:purchase_credit, source_type: 'BorrowerPaidOutsideClosing', credit_type: '', amount: BigDecimal.new('430.00')),
          build_stubbed(:purchase_credit, source_type: '', credit_type: 'EarnestMoney', amount: BigDecimal.new('250.00'))
        ]

        expect(subject.total_poc).to eq BigDecimal.new('680.00')
      end
    end

    it 'requires one of the targeted product codes' do
      loan.stub(product_code: 'C30FXD') 
      loan.stub purchase_credits: [
        build_stubbed(:purchase_credit, source_type: 'BorrowerPaidOutsideClosing', credit_type: '', amount: BigDecimal.new('320.00')),
        build_stubbed(:purchase_credit, source_type: '', credit_type: 'EarnestMoney', amount: BigDecimal.new('140.00'))
      ]

      expect(subject.total_poc).to eq 0
    end

    it "requires the targeted source type" do
      loan.stub(product_code: 'FHA30 MSHDA')
      loan.stub purchase_credits: [
        build_stubbed(:purchase_credit, source_type: 'Foo', credit_type: '', amount: BigDecimal.new('320.00')),
        build_stubbed(:purchase_credit, source_type: '', credit_type: 'EarnestMoney', amount: BigDecimal.new('140.00'))
      ]

      expect(subject.total_poc).to eq 0
    end

    it "requires the targeted credit type" do
      loan.stub(product_code: 'FHA30 IDHA IL FH') 
      loan.stub purchase_credits: [
        build_stubbed(:purchase_credit, source_type: 'BorrowerPaidOutsideClosing', credit_type: '', amount: BigDecimal.new('320.00')),
        build_stubbed(:purchase_credit, source_type: '', credit_type: 'Foo', amount: BigDecimal.new('140.00'))
      ]

      expect(subject.total_poc).to eq 0
    end

  end

  describe "flood_escrow_months" do
    it "should be 0 if there are no matching hud lines" do
      expect(subject.flood_escrow_months).to eq 0
    end

    it "should add all the months from lines with the right category and fee" do
      loan.stub hud_lines: [
          build_stubbed(:hud_line, fee_category: "InitialEscrowPaymentAtClosing", sys_fee_name: 'Flood Insurance', hud_type: 'GFE', num_months: 5),
          build_stubbed(:hud_line, fee_category: "InitialEscrowPaymentAtClosing", sys_fee_name: 'Flood Insurance ABC', hud_type: 'GFE', num_months: 6),
          build_stubbed(:hud_line, fee_category: "InitialEscrowPaymentAtClosing", sys_fee_name: 'Flood Insurance ABC', hud_type: 'GFE', num_months: nil),
          build_stubbed(:hud_line, fee_category: "InitialEscrowPaymentAtClosing",  sys_fee_name: 'sdlfkdj', hud_type: 'GFE', num_months: 9),
          build_stubbed(:hud_line, fee_category: "flsfjd", sys_fee_name: 'Flood Insurance ABC', hud_type: 'GFE', num_months: 10),
          build_stubbed(:hud_line, fee_category: "InitialEscrowPaymentAtClosing", sys_fee_name: 'Flood Insurance ABC', hud_type: 'HUD', num_months: 11),
        ]
   
      expect(subject.flood_escrow_months).to eq 5+6
    end
  end

  describe "financed_fee_indicator" do
    it "should return Financed if Mi funding Fee financed amount is greater than $0" do
      loan.stub_chain(:transaction_detail, mi_and_funding_fee_financed_amount: BigDecimal.new('12.3'))
      expect(subject.financed_fee_indicator).to eq 'Financed'
    end

    it "should return Not Financed when the value is nil" do
      expect(subject.financed_fee_indicator).to eq 'Not Financed'
    end

    it "should return Not Financed when the value is 0" do
      loan.stub_chain(:transaction_detail, mi_and_funding_fee_financed_amount: BigDecimal.new('0'))
      expect(subject.financed_fee_indicator).to eq 'Not Financed'
    end
  end

  describe "Do Not Wish to Furnish Borrower" do
    let(:government_monitoring) { GovernmentMonitoring.new}
    before do 
      loan.stub loan_general: loan_general
      loan.loan_general.stub(:government_monitorings) {government_monitoring}
    end
    context "When the box is checked" do
      it "should return Not Furnished" do
        government_monitorings = [ 
          build_stubbed(:government_monitoring, borrower_id: 'BRW1', race_national_origin_refusal_indicator: true),
          build_stubbed(:government_monitoring, borrower_id: 'BRW2', race_national_origin_refusal_indicator: true),
          build_stubbed(:government_monitoring, borrower_id: 'BRW3', race_national_origin_refusal_indicator: true),
          build_stubbed(:government_monitoring, borrower_id: 'BRW4', race_national_origin_refusal_indicator: true)
        ]
        allow(loan.loan_general.government_monitorings).to receive(:order).and_return(government_monitorings)
        expect(subject.do_not_wish_to_furnish_borrower1).to eq 'Not Furnished'
        expect(subject.do_not_wish_to_furnish_borrower2).to eq 'Not Furnished'
        expect(subject.do_not_wish_to_furnish_borrower3).to eq 'Not Furnished'
        expect(subject.do_not_wish_to_furnish_borrower4).to eq 'Not Furnished'
      end

      it "should return value from BRW3 when BRW2 is missing" do
        government_monitorings = [ 
          build_stubbed(:government_monitoring, borrower_id: 'BRW1', race_national_origin_refusal_indicator: true),
          build_stubbed(:government_monitoring, borrower_id: 'BRW3', race_national_origin_refusal_indicator: true)
        ]
        allow(loan.loan_general.government_monitorings).to receive(:order).and_return(government_monitorings)
        expect(subject.do_not_wish_to_furnish_borrower1).to eq 'Not Furnished'
        expect(subject.do_not_wish_to_furnish_borrower2).to eq 'Not Furnished'
        expect(subject.do_not_wish_to_furnish_borrower3).to eq 'Furnished'
        expect(subject.do_not_wish_to_furnish_borrower4).to eq 'Furnished'
      end
    end

    context "When box is not checked" do
      it "should return as Furnished" do
        government_monitorings = [ 
          build_stubbed(:government_monitoring, borrower_id: 'BRW1', race_national_origin_refusal_indicator: false),
          build_stubbed(:government_monitoring, borrower_id: 'BRW2', race_national_origin_refusal_indicator: false),
          build_stubbed(:government_monitoring, borrower_id: 'BRW3', race_national_origin_refusal_indicator: false),
          build_stubbed(:government_monitoring, borrower_id: 'BRW4', race_national_origin_refusal_indicator: false)
        ]
        allow(loan.loan_general.government_monitorings).to receive(:order).and_return(government_monitorings)
        expect(subject.do_not_wish_to_furnish_borrower1).to eq 'Furnished'
        expect(subject.do_not_wish_to_furnish_borrower2).to eq 'Furnished'
        expect(subject.do_not_wish_to_furnish_borrower3).to eq 'Furnished'
        expect(subject.do_not_wish_to_furnish_borrower4).to eq 'Furnished'
      end
    end
  end

  describe "homeowners_insurance_condo_master_policy_effective_date" do
    it "should return nil when there are no matching entries" do
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with(form_unique_name: "Expirations Dates", attribute_unique_name: "CondoMPEffectiveDate").and_return([])
      allow(loan).to receive(:custom_fields).and_return(custom_field)
      expect(subject.homeowners_insurance_condo_master_policy_effective_date).to be_nil
    end

    it "should return date when matching entries found" do
      fields = [ build_stubbed(:custom_field, form_unique_name: "Expirations Dates", attribute_unique_name: "Condo MP ExpDate", attribute_value: DateTime.new(2015,1,1)), build_stubbed(:custom_field, form_unique_name: "Expirations Dates", attribute_unique_name: "CondoMPEffectiveDate", attribute_value: DateTime.new(2015,1,1))]
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with(form_unique_name: "Expirations Dates", attribute_unique_name: "CondoMPEffectiveDate").and_return(fields)
      allow(loan).to receive(:custom_fields).and_return(custom_field)
      expect(subject.homeowners_insurance_condo_master_policy_effective_date).to eq "01/01/2015"
    end

    it "should return date when the entry is available and value is of type string" do
      fields = [ build_stubbed(:custom_field, form_unique_name: "Expirations Dates", attribute_unique_name: "Condo MP ExpDate", attribute_value: "10/8/2015"), build_stubbed(:custom_field, form_unique_name: "Expirations Dates", attribute_unique_name: "CondoMPEffectiveDate", attribute_value: DateTime.new(2015,1,1))]
      custom_field = double("CustomField")
      allow(custom_field).to receive(:where).with(form_unique_name: "Expirations Dates", attribute_unique_name: "CondoMPEffectiveDate").and_return(fields)
      allow(loan).to receive(:custom_fields).and_return(custom_field)
      expect(subject.homeowners_insurance_condo_master_policy_effective_date).to eq "10/08/2015"
    end
  end

  describe "signature_date1003" do

    it "should return date if borrower 1 has a signature date" do
      date = DateTime.new(2016,2,1)
      borrowers = [build_stubbed(:borrower, borrower_id: 'BRW1', equifax_credit_score: 670, experian_credit_score: 660, trans_union_credit_score: 650, application_signed_date: date)]
      loan.stub(:borrowers) {borrowers}
      expect(subject.signature_date1003).to eq "02/01/2016"
    end

    it "should not return a date if borrower 1 has no signature date" do
      borrowers = [build_stubbed(:borrower, borrower_id: 'BRW1', equifax_credit_score: 670, experian_credit_score: 660, trans_union_credit_score: 650)]
      loan.stub(:borrowers) {borrowers}
      expect(subject.signature_date1003).to be_nil
    end

    it "should not return the signature date of borrowers other than 1" do
      date = Time.now
      borrowers = [build_stubbed(:borrower, borrower_id: 'BRW2', equifax_credit_score: 670, experian_credit_score: 660, trans_union_credit_score: 650, application_signed_date: date)]
      loan.stub(:borrowers) {borrowers}
      expect(subject.signature_date1003).to be_nil
    end

  end

  describe "cash_from_to_borrower" do
    let(:td) { FactoryGirl.build_stubbed(:transaction_detail, purchase_price_amount: BigDecimal.new('23.4'), refinance_including_debts_to_be_paid_off_amount: BigDecimal.new('45'), prepaid_items_estimated_amount: BigDecimal.new('0'), estimated_closing_costs_amount: BigDecimal.new('34.5'), seller_paid_closing_costs_amount: BigDecimal.new('25'), purchase_price_amount: BigDecimal.new('70')) }
    let(:mt) { FactoryGirl.build_stubbed(:mortgage_term, base_loan_amount: BigDecimal.new('10')) }
    let(:pc) { FactoryGirl.build_stubbed(:purchase_credit) }
    let(:ls) { FactoryGirl.build_stubbed(:liability)}

    before do
      loan.stub transaction_detail: td
      loan.stub mortgage_term: mt
      loan.stub purchase_credits: pc
      loan.stub liabilities: ls
      loan.stub hud_lines: [
        build_stubbed(:hud_line, sys_fee_name: "Discount Points", total_amt: 30, hud_type: 'HUD'),
        build_stubbed(:hud_line, sys_fee_name: "Discount Points", total_amt: 50, hud_type: 'GFE'),
      ]

      allow(ls).to receive(:first).and_return(double("Liability", unpaid_balance_amount: BigDecimal.new('49.4')))
    end

    context "loan type is refinance" do
      it "should return the summation of the equation" do
        loan.stub loan_type: "Refinance"
        allow(pc).to receive(:pluck).with(:amount).and_return([BigDecimal.new('12.3'), BigDecimal.new('34.4'), nil])
        expect(subject.cash_from_to_borrower).to eq (49.4 - 10 + 0 +34.5 - (12.3+34.4) + 0 + 30).round(2)
      end
    end

    context "loan type is Purchase" do
      it "should return the summation of the equation" do
        loan.stub loan_type: "Purchase"
        allow(pc).to receive(:pluck).with(:amount).and_return([BigDecimal.new('12.3'), BigDecimal.new('34.4'), nil])
        expect(subject.cash_from_to_borrower).to eq (70 - 10 + 0 +34.5 - (12.3+34.4) + 0 - 25 + 30).round(2)
      end
    end

    it "should return 0 when there are no values" do
      loan.stub transaction_detail: FactoryGirl.build_stubbed(:transaction_detail)
      loan.stub mortgage_term: FactoryGirl.build_stubbed(:mortgage_term)
      allow(pc).to receive(:pluck).with(:amount).and_return([])
      expect(subject.cash_from_to_borrower).to eq 0
    end
  end

  describe "renewal_schedule_mortgage_insurance_amount" do

    it "should calculate amount for first renewal" do
      renewal = double
      allow(renewal).to receive(:rate).and_return 1.15
      loan.stub_chain(:loan_general, :mi_renewal_premia, :first_premium) { renewal }
      loan.stub_chain(:loan_general, :mortgage_term, :borrower_requested_loan_amount) { 381900.00 }
      expect(subject.renewal_schedule_mortgage_insurance_amount).to eq 365.99
    end

    it "should not calculate amount for non-renewal" do
      loan.stub_chain(:loan_general, :mi_renewal_premia, :first_premium) { nil }
      loan.stub_chain(:loan_general, :mortgage_term, borrower_requested_loan_amount: nil)
      expect(subject.renewal_schedule_mortgage_insurance_amount).to eq 0.00

      loan.stub_chain(:loan_general, :mortgage_term, :borrower_requested_loan_amount) { 381900.00 }
      expect(subject.renewal_schedule_mortgage_insurance_amount).to eq 0.00
    end

  end

  describe "lender_paid_broker_compensation_amount" do

    it "should return the total amount if it exists for gfe line" do
      loan.stub_chain(:hud_lines, :gfe, :hud_line_value).with("Lender Paid Broker Compensation") { BigDecimal.new("115000.0") }
      expect(subject.lender_paid_broker_compensation_amount).to eq 115000.00
    end

    it "should return 0 if there is no total for gfe line" do
      loan.stub_chain(:hud_lines, :gfe, :hud_line_value).with("Lender Paid Broker Compensation") { 0.0 } # hud_line_value returns 0.0 for nil
      expect(subject.lender_paid_broker_compensation_amount).to eq 0.00
    end

    it "should return 0 if the gfe line does not exist" do
      expect(subject.lender_paid_broker_compensation_amount).to eq 0.00
    end

  end

  describe "homebuyer_education_fee" do
    it "should return 0 if no matching records found" do
      loan.stub(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: "Credit Report", total_amt: 200)]}
      expect(subject.homebuyer_education_fee).to eq 0
    end

    it "should return amount if it matches" do
      loan.stub hud_lines: [
        build_stubbed(:hud_line, sys_fee_name: "Homebuyer Education Fee", total_amt: 301, hud_type: 'HUD'),
        build_stubbed(:hud_line, sys_fee_name: "Homebuyer Education Fee", total_amt: 300, hud_type: 'GFE'),
      ]
      expect(subject.homebuyer_education_fee).to eq 300
    end
  end

  describe "lender_paid_compensation_tier_amount" do
    it "should return 0.0 when there is no price adjustment matches" do
      loan.stub price_adjustments: [build_stubbed(:price_adjustment, label: "price adjustment", amount: BigDecimal.new('10.2'))]
      expect(subject.lender_paid_compensation_tier_amount).to eq 0.0
    end

    it "should return the calculated value" do
      loan.stub price_adjustments: [build_stubbed(:price_adjustment, label: "price adjustment", amount: BigDecimal.new('10.2')), build_stubbed(:price_adjustment, label: "Originator Compensation is Lender Paid and InstId is 21568 then price adjustment = 1.23", amount: BigDecimal.new('1.23'))]
      loan.stub_chain(:lock_loan_datum, total_loan_amt: 100_000)
      expect(subject.lender_paid_compensation_tier_amount).to eq 1230.00
    end

    it "should return +ve value when the PriceAdjustment.amount value is negative" do
      loan.stub price_adjustments: [build_stubbed(:price_adjustment, label: "price adjustment", amount: BigDecimal.new('10.2')), build_stubbed(:price_adjustment, label: "Originator Compensation is Lender Paid and InstId is 21568 then price adjustment = 2.35", amount: BigDecimal.new('-2.5'))]
      loan.stub_chain(:lock_loan_datum, total_loan_amt: 100_000)
      expect(subject.lender_paid_compensation_tier_amount).to eq 2500.00
    end
  end

  describe "institutional_broker_compensation_tier_amount" do
    it "should come from loan comp tier times loan amt" do
      loan.stub comp_tier: double(comp_tier: 0.015)
      loan.stub_chain(:mortgage_term, :borrower_requested_loan_amount).and_return(100_000)
      expect(subject.institutional_broker_compensation_tier_amount).to eq 1500.0
    end

    it "should be ok if comp tier is missing" do
      loan.stub comp_tier: nil
      loan.stub_chain(:mortgage_term, :borrower_requested_loan_amount).and_return(100_000)
      expect(subject.institutional_broker_compensation_tier_amount).to eq 0
    end

    it "should be 0 if amount is missing" do
      loan.stub comp_tier: double(comp_tier: 0.015)
      loan.stub mortgage_term: nil
      expect(subject.institutional_broker_compensation_tier_amount).to eq 0
    end
  end

  describe "fully_indexed_rate" do
    before do
      loan.stub arm: double("Arm")
    end

    [[BigDecimal.new('1.23'), BigDecimal.new('5.6'), 6.875],
      [BigDecimal.new('4.23'), BigDecimal.new('1.2'), 5.375],
      [BigDecimal.new('5'), BigDecimal.new('5.123'), 10.125]
    ].each do |curr_val, margin_perc, roundval|
      it "should return the rounded value" do
        loan.arm.stub index_current_value_percent: curr_val
        loan.arm.stub index_margin_percent: margin_perc

        expect(subject.fully_indexed_rate).to eq roundval
      end
    end

    it "should return 0.0 when no value present" do
      loan.arm.stub index_current_value_percent: nil
      loan.arm.stub index_margin_percent: nil
      expect(subject.fully_indexed_rate).to eq 0.0
    end
  end
end

