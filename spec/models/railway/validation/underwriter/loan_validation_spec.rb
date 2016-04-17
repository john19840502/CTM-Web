require 'spec_helper'

describe Validation::Underwriter::LoanValidation do
  let(:clean_loan) { Loan.new(loan_amount: 100000) }

  subject { Validation::Underwriter::LoanValidation.new(clean_loan) }

  context 'loan has a loan general' do
    let(:loan_general) { LoanGeneral.new }

    before do
      clean_loan.stub(:loan_general) { loan_general }
      clean_loan.id.should == nil # this is just a verification check that set up is correctly executed.
    end

    context ':check_property_county' do
      describe 'property address not provided' do
        before do
          clean_loan.property_city = clean_loan.property_state = clean_loan.property_zip = nil
          subject.check_property_county
        end
        
        it 'should require property address to be valid' do
          expect(subject.warnings).to eq([ 'Property County can not be verified for this Property Address. Please verify address validity.'])
        end
      end

      context 'property address is provided' do
        before do
          clean_loan.property_city = 'Oak Park'
          clean_loan.property_state = 'MI'
          clean_loan.property_zip = '48237'
        end
        
        describe 'property_county not provided' do
          it 'should require property_county to be added' do
            subject.check_property_county
            expect(subject.errors).to eq ['Property County is not entered. Suggested County name is Oakland.']
          end
        end

        describe 'property_zip has +4 digits' do
          before do
            clean_loan.property_county = 'OAKLAND'
            clean_loan.property_zip = '482370000'
            subject.check_property_county
          end
          
          it 'should not return errors' do
            expect(subject.errors).to be_empty
          end
        end

        describe 'property_county is correct' do
          before do
            clean_loan.property_county = 'OAKLAND'
            subject.check_property_county
          end
          
          it 'should not return errors' do
            expect(subject.errors).to be_empty
          end
        end
      end
    end

    context 'govt_monitoring_app_taken_by_required' do
      describe 'and application_taken_method_type is blank' do 
        before do 
          clean_loan.stub(:interviewer) { build_stubbed :interviewer, application_taken_method_type: '' }
          subject.govt_monitoring_app_taken_by_required
        end

        it 'should require application_taken_method_type' do
          expect(subject.errors).to eq [ '1003 - government monitoring - application taken by must be completed.']
        end
      end

      describe 'and application_taken_method_type is not blank' do 
        before do 
          clean_loan.stub(:interviewer) { build_stubbed :interviewer, application_taken_method_type: 'SomeType' }
          subject.govt_monitoring_app_taken_by_required
        end

        it 'should not return errors' do
          expect(subject.errors).to be_empty
        end
      end
    end

    context 'govt_monitoring_app_taken_by_f2f_ethnicity_gender_race_are_required' do 
      before do 
        clean_loan.stub(:interviewer) { build_stubbed :interviewer, application_taken_method_type: 'FaceToFace' }
        loan_general.stub(:borrowers) { [build_stubbed(:borrower, borrower_id: 'BRW1')] }
      end

      describe 'nothing set' do
        before do 
          loan_general.stub(:government_monitorings) { [build_stubbed(:government_monitoring, gender_type: 'Neither', borrower_id: 'BRW1')] }
          subject.govt_monitoring_app_taken_by_f2f_ethnicity_gender_race_are_required 
        end
        
        it 'should require gender, ethnicity, and race info completed' do
          expect(subject.errors).to eq ['Application was taken face to face, government monitoring information must be completed and cannot be "Information not Provided"']
        end
      end

      describe 'gender set' do 
        before do
          loan_general.stub(:government_monitorings) { [build_stubbed(:government_monitoring, gender_type: 'Male', borrower_id: 'BRW1')] }
          subject.govt_monitoring_app_taken_by_f2f_ethnicity_gender_race_are_required
        end

        it 'should require gender, ethnicity, and race info completed' do
          expect(subject.errors).to eq ['Application was taken face to face, government monitoring information must be completed and cannot be "Information not Provided"']
        end
      end

      describe 'gender and ethnicity set' do 
        before do
          loan_general.stub(:government_monitorings) { [build_stubbed(:government_monitoring, gender_type: 'Male', hmda_ethnicity_type: 'HispanicOrLatino', borrower_id: 'BRW1')] }
          subject.govt_monitoring_app_taken_by_f2f_ethnicity_gender_race_are_required
        end

        it 'should require gender, ethnicity, and race info completed' do
          expect(subject.errors).to eq ['Application was taken face to face, government monitoring information must be completed and cannot be "Information not Provided"']
        end
      end

      describe 'gender, ethnicity and race are set' do 
        before do
          loan_general.stub(:government_monitorings) { [build_stubbed(:government_monitoring, gender_type: 'Male', hmda_ethnicity_type: 'HispanicOrLatino', borrower_id: 'BRW1')] }
          loan_general.stub(:hmda_races) { [build_stubbed(:hmda_race, hmda_race_type: 'White', borrower_id: 'BRW1')] }
          subject.govt_monitoring_app_taken_by_f2f_ethnicity_gender_race_are_required
        end

        it 'should return no erros' do
          expect(subject.errors).to be_empty
        end
      end

      describe 'gender, ethnicity and race are set but only for 1 borrower' do 
        before do
          loan_general.stub(:borrowers) { [ build_stubbed(:borrower, borrower_id: 'BRW1'), build_stubbed(:borrower, borrower_id: 'BRW2') ] }
          loan_general.stub(:government_monitorings) { [build_stubbed(:government_monitoring, gender_type: 'Male', hmda_ethnicity_type: 'HispanicOrLatino', borrower_id: 'BRW1')] }
          loan_general.stub(:hmda_races) { [build_stubbed(:hmda_race, hmda_race_type: 'White', borrower_id: 'BRW1')] }
          subject.govt_monitoring_app_taken_by_f2f_ethnicity_gender_race_are_required
        end

        it 'should require gender, ethnicity, and race info completed' do
          expect(subject.errors).to eq ['Application was taken face to face, government monitoring information must be completed and cannot be "Information not Provided"']
        end
      end
    end

    context 'and application_taken_method_type is other than FaceToFace' do 
      before do 
        clean_loan.stub(:interviewer) { build_stubbed :interviewer, application_taken_method_type: 'Internet' }
        loan_general.stub(:borrowers) { [ build_stubbed(:borrower, borrower_id: 'BRW1') ] }
      end
      
      it 'should require gender, ethnicity, and race info completed' do
        subject.govt_monitoring_app_taken_by_not_f2f_ethnicity_gender_race_are_required
        expect(subject.warnings).to eq ['Government Monitoring information is not complete.']
      end

      describe ':govt_monitoring_app_taken_by_not_f2f_ethnicity_gender_race_are_required' do 
        before do
          loan_general.stub(:government_monitorings) { [build_stubbed(:government_monitoring, gender_type: 'NotApplicable')]}
          subject.govt_monitoring_app_taken_by_not_f2f_ethnicity_gender_race_are_required
        end

        it 'should require gender, ethnicity, and race info completed' do
          expect(subject.warnings).to eq ['Government Monitoring information is not complete.']
        end
      end

      describe ':govt_monitoring_app_taken_by_not_f2f_ethnicity_gender_race_are_required' do 
        before do
          loan_general.stub(:government_monitorings) { [build_stubbed(:government_monitoring, gender_type: 'InformationNotProvidedUnknown', hmda_ethnicity_type: 'InformationNotProvidedByApplicantInMailInternetOrTelephoneApplication')]}
          subject.govt_monitoring_app_taken_by_not_f2f_ethnicity_gender_race_are_required
        end

        it 'should require gender, ethnicity, and race info completed' do
          expect(subject.warnings).to eq ['Government Monitoring information is not complete.']
        end
      end

      describe ':govt_monitoring_app_taken_by_not_f2f_ethnicity_gender_race_are_required' do 
        before do
          loan_general.stub(:government_monitorings) { [build_stubbed(:government_monitoring, gender_type: 'NotApplicable', hmda_ethnicity_type: 'NotHispanicOrLatino', borrower_id: 'BRW1')]}
          loan_general.stub(:hmda_races) { [build_stubbed(:hmda_race, hmda_race_type: 'AmericanIndianOrAlaskaNative', borrower_id: 'BRW1')]}
          subject.govt_monitoring_app_taken_by_not_f2f_ethnicity_gender_race_are_required
        end

        it 'should return no erros' do
          expect(subject.errors).to be_empty
        end
      end

      describe ":govt_monitoring_app_taken_by_not_f2f_ethnicity_gender_race_are_required :: only 1 borrower's info is set up" do 
        before do
          loan_general.stub(:borrowers) { [build_stubbed(:borrower, borrower_id: 'BRW1'), build_stubbed(:borrower, borrower_id: 'BRW2')] }
          loan_general.stub(:government_monitorings) { [build_stubbed(:government_monitoring, gender_type: 'NotApplicable', hmda_ethnicity_type: 'NotHispanicOrLatino', borrower_id: 'BRW1')]}
          loan_general.stub(:hmda_races) { [build_stubbed(:hmda_race, hmda_race_type: 'AmericanIndianOrAlaskaNative', borrower_id: 'BRW1')]}
          subject.govt_monitoring_app_taken_by_not_f2f_ethnicity_gender_race_are_required
        end

        it 'should require gender, ethnicity, and race info completed' do
          expect(subject.warnings).to eq ['Government Monitoring information is not complete.']
        end
      end
    end

    describe ':ltv_80_less_should_not_enter_mi_data_or_monthly_mi_pmnt' do
      context 'and ltv is 80 percent or less' do
        before do 
          clean_loan.stub(:loan_feature) { build_stubbed(:loan_feature, product_name: "C5/1ARM LIB HIBAL") }
          loan_general.stub(:lock_loan_datum) { build_stubbed(:lock_loan_datum, ltv: 80) }
          loan_general.stub(:proposed_housing_expenses) {[build_stubbed(:proposed_housing_expense, housing_expense_type: 'MI', payment_amount: 25.00)]}
        end

        it 'should return a warning message' do
          subject.ltv_80_less_should_not_enter_mi_data_or_monthly_mi_pmnt
          expect(subject.errors).to eq ['LTV is 80% or less. There is a mortgage insurance payment entered in the Proposed housing section. Remove all MI information from the 1003, MI Calc screen and MI screen.']
        end

        context 'and product_name starts with FHA' do
          it 'should not return a warning message' do
            clean_loan.stub(:loan_feature) { build_stubbed(:loan_feature, product_name: "FHA30FXD") }
            subject.ltv_80_less_should_not_enter_mi_data_or_monthly_mi_pmnt
            expect(subject.errors).to be_empty
          end
        end
      end
    end

    context 'and underwriting_condition condition "Maximum approved funds" exists and has amount in it' do
      context 'and transaction_detail total_funds_required_to_close is gt 0' do
        context 'and amount in message is 0' do
          before do 
            loan_general.stub(:underwriting_conditions) {[build_stubbed(:underwriting_condition, condition: 'Maximum approved funds $0')]}
            loan_general.stub(:transaction_detail) {build_stubbed(:transaction_detail, purchase_price_amount: 6000)}
          end

          describe ':total_funds_required_to_close_gt_0_max_approved_funds_condition_amount_must_be_gt_total_funds_required_to_close' do
            before do
              loan_general.stub(:loan_purpose) {build_stubbed(:loan_purpose, loan_type: "Purchase")}
              subject.total_funds_required_to_close_gt_0_max_approved_funds_condition_amount_must_be_gt_total_funds_required_to_close
            end

            it 'should return a warning message' do
              expect(subject.errors).to eq ['Max funds for closing condition do not reflect sufficient funds for closing.']
            end
          end

          describe ':total_funds_required_to_close_gt_0_max_approved_funds_condition_amount_must_be_gt_total_funds_required_to_close' do
            before do
              loan_general.stub(:loan_purpose) {build_stubbed(:loan_purpose, loan_type: "Refinance")}
              subject.total_funds_required_to_close_gt_0_max_approved_funds_condition_amount_must_be_gt_total_funds_required_to_close
            end

            it 'should return a warning message' do
              expect(subject.errors).to eq ['Max funds for closing condition do not reflect sufficient funds for closing.']
            end
          end
        end
  
        context "and amount in the message is greater than 0" do
          before do 
            loan_general.stub(:underwriting_conditions) {[build_stubbed(:underwriting_condition, condition: 'Maximum approved funds $5000')]}
            loan_general.stub(:transaction_detail) {build_stubbed(:transaction_detail, purchase_price_amount: 6000)}
          end

          describe ':total_funds_required_to_close_gt_0_max_approved_funds_condition_amount_must_be_gt_total_funds_required_to_close' do
            before { subject.total_funds_required_to_close_gt_0_max_approved_funds_condition_amount_must_be_gt_total_funds_required_to_close }

            it 'should return a warning message' do
              expect(subject.errors).to eq ['Max funds for closing condition do not reflect sufficient funds for closing.']
            end
          end

          describe ':total_funds_required_to_close_gt_0_max_approved_funds_condition_amount_must_be_gt_total_funds_required_to_close' do
            before do 
              loan_general.stub(:transaction_detail) {build_stubbed(:transaction_detail, purchase_price_amount: 5000)}
              subject.total_funds_required_to_close_gt_0_max_approved_funds_condition_amount_must_be_gt_total_funds_required_to_close
            end  

            it 'should not return any messages' do
              expect(subject.errors).to be_empty
            end
          end
        end

        context "and product is IRRL" do
          describe ':total_funds_required_to_close_gt_0_max_approved_funds_condition_amount_must_be_gt_total_funds_required_to_close' do
            before do
              loan_general.stub(:underwriting_conditions) {[build_stubbed(:underwriting_condition, condition: 'Maximum approved funds $5000')]}
              loan_general.stub(:transaction_detail) {build_stubbed(:transaction_detail, purchase_price_amount: 6000)}
              clean_loan.stub(:loan_feature) { build_stubbed(:loan_feature, product_name: "FH30IRRL") }
              subject.total_funds_required_to_close_gt_0_max_approved_funds_condition_amount_must_be_gt_total_funds_required_to_close
            end

            it 'should not trigger this validation' do
              expect(subject.errors).to be_empty
            end
          end
        end
      end
    end

    describe ':liability_account_type_heloc_and_resubordinated_requires_undrawn_heloc_amnt' do
      context 'and liability type "HELOC"' do
        before do 
          loan_general.stub(:liabilities) {[build_stubbed(:liability, liability_type: 'HELOC', subject_loan_resubordination_indicator: true)]}
        end
                
        describe 'undrawn_heloc_amount not set' do
          before { subject.liability_account_type_heloc_and_resubordinated_requires_undrawn_heloc_amnt }

          it 'should return a warning message' do
            expect(subject.errors).to eq ['A resubordinated HELOC is entered, verify either full line is drawn or complete undrawn HELOC amount of the details of transaction tab.']
          end
        end

        describe 'undrawn_heloc_amount is set' do
          before do
            loan_general.stub(:transaction_detail) { build_stubbed(:transaction_detail, undrawn_heloc_amount: 6000) }
            subject.liability_account_type_heloc_and_resubordinated_requires_undrawn_heloc_amnt 
          end

          it 'should not return any messages' do
            expect(subject.errors).to be_empty
          end
        end
      end
    end

    describe ':cltv_gt_ltv_requires_proposed_housing_other_financing_gt_zero' do
      context 'and ltv is less than cltv' do
        describe ':cltv_gt_ltv_requires_proposed_housing_other_financing_gt_zero' do
          before do 
            clean_loan.stub(:ltv) { 80 }
            clean_loan.stub(:cltv) { 80.001 }
            subject.cltv_gt_ltv_requires_proposed_housing_other_financing_gt_zero 
          end

          it 'should require payment_amount on other_housing_expense in proposed_housing_expense' do
            expect(subject.warnings).to eq ['If the CLTV is greater than LTV then the proposed Housing Other Financing amount must be greater than 0.00']
          end
        end

        context 'and amount is greater than 0' do
          before do 
            loan_general.stub(:lock_loan_datum) { build_stubbed(:lock_loan_datum, ltv: 80, cltv: 80.001) }
            subject.cltv_gt_ltv_requires_proposed_housing_other_financing_gt_zero
          end

          it 'should not return any messages' do
            expect(subject.errors).to be_empty
          end
        end
      end
    end

    describe 'other_financing_gt_0_on_proposed_housing_expense_requires_cltv_gt_ltv' do
      context 'and ltv is less than cltv and amount is greater than 0' do
        describe ':other_financing_gt_0_on_proposed_housing_expense_requires_cltv_gt_ltv' do
          before do
            loan_general.stub(:lock_loan_datum) { build_stubbed(:lock_loan_datum, ltv: 82, cltv: 80.001) }
            loan_general.stub(:proposed_housing_expenses) {[build_stubbed(:proposed_housing_expense, payment_amount: 2500, housing_expense_type: 'OtherMortgageLoanPrincipalAndInterest')]}
            clean_loan.locked_at = 10.days.ago 
            clean_loan.lock_expiration_at = 10.days.from_now
            subject.other_financing_gt_0_on_proposed_housing_expense_requires_cltv_gt_ltv 
          end

          it 'should require cltv to be greater than ltv' do
            expect(subject.errors).to eq ['Other financing is entered in the Proposed Housing section but subordinate financing is not reflected in the CLTV']
          end
        end

        describe ':other_financing_gt_0_on_proposed_housing_expense_requires_cltv_gt_ltv' do
          before do 
            loan_general.stub(:lock_loan_datum) { build_stubbed(:lock_loan_datum, ltv: 80, cltv: 80.001) }
            subject.cltv_gt_ltv_requires_proposed_housing_other_financing_gt_zero
          end

          it 'should not return any messages' do
            expect(subject.errors).to be_empty
          end
        end
      end
    end

    context 'and loan_purpose property_usage_type is SecondHome or Investor' do
      before do
        loan_general.stub(:loan_purpose) {build_stubbed(:loan_purpose, property_usage_type: "SecondHome")}
      end

      context 'and reo_property maintenance_expense_amount eq 0 and current_residence_indicator eq true' do
        before do
          loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, maintenance_expense_amount: 0, current_residence_indicator: true, reo_id: 'R1')] }
        end

        describe ':occupancy_second_or_investment_and_ins_maint_taxes_not_gt_0_on_reo_record_marked_current_must_not_have_haz_ins_and_real_est_taxes_on_curr_housing_exp' do
          before do
            loan_general.stub(:present_housing_expenses) { [build_stubbed(:present_housing_expense, housing_expense_type: 'HazardInsurance', payment_amount: 25)] }
            subject.occupancy_second_or_investment_and_ins_maint_taxes_not_gt_0_on_reo_record_marked_current_must_not_have_haz_ins_and_real_est_taxes_on_curr_housing_exp
          end

          context 'proposed_housing_expense housing_expense_type eq HazardInsurance or RealEstateTax and payment_amount is not 0' do
            it 'should return a error message' do
              expect(subject.errors).to eq ['REO does not have taxes and insurance separate for current residence but Housing expense reflects taxes and insurance broken out.']
            end
          end
        end

        describe ':occupancy_second_or_investment_and_ins_maint_taxes_not_gt_0_on_reo_record_marked_current_must_not_have_haz_ins_and_real_est_taxes_on_curr_housing_exp' do
          before do
            loan_general.stub(:present_housing_expenses) { [build_stubbed(:present_housing_expense, housing_expense_type: 'RealEstateTax', payment_amount: 25)] }
            subject.occupancy_second_or_investment_and_ins_maint_taxes_not_gt_0_on_reo_record_marked_current_must_not_have_haz_ins_and_real_est_taxes_on_curr_housing_exp
          end

          context 'proposed_housing_expense housing_expense_type eq HazardInsurance or RealEstateTax and payment_amount is not 0' do
            it 'should return a warning message' do
              expect(subject.errors).to eq ['REO does not have taxes and insurance separate for current residence but Housing expense reflects taxes and insurance broken out.']
            end
          end
        end

        describe ':occupancy_second_or_investment_and_ins_maint_taxes_not_gt_0_on_reo_record_marked_current_must_not_have_haz_ins_and_real_est_taxes_on_curr_housing_exp' do
          before do
            loan_general.stub(:present_housing_expenses) { [build_stubbed(:present_housing_expense, housing_expense_type: 'RealEstateTax', payment_amount: 25)] }
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, maintenance_expense_amount: 0, current_residence_indicator: true, reo_id: 'R2')] }
            subject.occupancy_second_or_investment_and_ins_maint_taxes_not_gt_0_on_reo_record_marked_current_must_not_have_haz_ins_and_real_est_taxes_on_curr_housing_exp 
          end

          it 'should return a warning message' do
            expect(subject.errors).to eq ['REO does not have taxes and insurance separate for current residence but Housing expense reflects taxes and insurance broken out.']
          end
        end

        describe ':occupancy_second_or_investment_and_ins_maint_taxes_not_gt_0_on_reo_record_marked_current_must_not_have_haz_ins_and_real_est_taxes_on_curr_housing_exp' do
          before do
            loan_general.stub(:present_housing_expenses) { [build_stubbed(:present_housing_expense, housing_expense_type: 'OtherHousingExpense', payment_amount: 25)] }
            subject.occupancy_second_or_investment_and_ins_maint_taxes_not_gt_0_on_reo_record_marked_current_must_not_have_haz_ins_and_real_est_taxes_on_curr_housing_exp 
          end

          it 'otherwise should not return any messages' do
            expect(subject.errors).to be_empty
          end
        end
      end

      context 'and reo_property maintenance_expense_amount not eq 0 or current_residence_indicator not eq true' do
        before do
          loan_general.stub(:present_housing_expenses) { [build_stubbed(:present_housing_expense, housing_expense_type: 'RealEstateTax', payment_amount: 25)] }
        end

        describe ':occupancy_second_or_investment_and_ins_maint_taxes_not_gt_0_on_reo_record_marked_current_must_not_have_haz_ins_and_real_est_taxes_on_curr_housing_exp' do
          before do
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, maintenance_expense_amount: 0, current_residence_indicator: false, reo_id: 'R1')] }
            subject.occupancy_second_or_investment_and_ins_maint_taxes_not_gt_0_on_reo_record_marked_current_must_not_have_haz_ins_and_real_est_taxes_on_curr_housing_exp 
          end

          it 'should not return any messages' do
            expect(subject.errors).to be_empty
          end
        end
      end
    end

    describe ':occupancy_second_or_investment_and_purpose_refinance_requires_reo_must_have_current_subject_indicator_set_to_subject' do
      context 'and loan_purpose property_usage_type is SecondHome or Investor and loan_purpose type eql "Refinance" and reo_id on reo_property is R1' do
        before do
          loan_general.stub(:loan_purpose) {build_stubbed(:loan_purpose, loan_type: "Refinance", property_usage_type: "SecondHome")}
        end

        describe 'subject_indicator not set' do
          before do 
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', subject_indicator: false)] }
            subject.occupancy_second_or_investment_and_purpose_refinance_requires_reo_must_have_current_subject_indicator_set_to_subject
          end

          context 'should require reo_property subject_indicator set to true' do
            it 'should return a warning message' do
              expect(subject.errors).to eq ['A REO record has not been entered that is marked subject property.']
            end
          end
        end

        describe 'reo_id not R1' do
          before { 
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R2')] }
            subject.occupancy_second_or_investment_and_purpose_refinance_requires_reo_must_have_current_subject_indicator_set_to_subject 
          }

          context 'should not require reo_property subject_indicator set to true' do
            it 'should return a warning message' do
              expect(subject.errors).to eq ['A REO record has not been entered that is marked subject property.']
            end
          end
        end

        describe 'all is set correctly' do
          before do
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', subject_indicator: true)] }
            subject.occupancy_second_or_investment_and_purpose_refinance_requires_reo_must_have_current_subject_indicator_set_to_subject
          end

          it 'should not return a warning message' do
            expect(subject.errors).to be_empty
          end
        end
      end
    end

    describe ':occupancy_second_or_investment_and_ins_maint_taxes_not_on_current_housing_expense_then_reo_record_marked_current_must_have_0_for_haz_ins_and_real_est_taxes' do
      context 'and loan_purpose property_usage_type is SecondHome or Investor and current_residence_indicator eq true and present_housing_expense housing_expense_type eq HazardInsurance or RealEstateTax and payment_amount is eq 0 or null' do
        before do
          loan_general.stub(:loan_purpose) {build_stubbed(:loan_purpose, loan_type: "Refinance", property_usage_type: "SecondHome")}
          loan_general.stub(:present_housing_expenses) { [build_stubbed(:present_housing_expense, housing_expense_type: 'HazardInsurance', payment_amount: 0)] }
        end

        context 'and reo_property maintenance_expense_amount is not eq 0' do
          before do
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', subject_indicator: true, maintenance_expense_amount: 25, current_residence_indicator: true)] }
            subject.occupancy_second_or_investment_and_ins_maint_taxes_not_on_current_housing_expense_then_reo_record_marked_current_must_have_0_for_haz_ins_and_real_est_taxes 
          end

          it 'should return a warning message' do
            expect(subject.errors).to eq ['Housing expense does not have taxes and insurance broken out but REO has taxes and insurance separate for current residence.']
          end
        end

        context 'and reo_property is not on R1' do
          before do
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R2', subject_indicator: true, maintenance_expense_amount: 25, current_residence_indicator: true)] }
            subject.occupancy_second_or_investment_and_ins_maint_taxes_not_on_current_housing_expense_then_reo_record_marked_current_must_have_0_for_haz_ins_and_real_est_taxes
          end

          it 'otherwise should not return any messages' do
            expect(subject.errors).to eq ['Housing expense does not have taxes and insurance broken out but REO has taxes and insurance separate for current residence.']
          end
        end

        context 'all is set correctly' do
          before do
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', subject_indicator: true, maintenance_expense_amount: 0, current_residence_indicator: true)] }
            subject.occupancy_second_or_investment_and_ins_maint_taxes_not_on_current_housing_expense_then_reo_record_marked_current_must_have_0_for_haz_ins_and_real_est_taxes 
          end

          it 'otherwise should not return any messages' do
            expect(subject.errors).to be_empty
          end
        end
      end

      context 'and current_residence_indicator eq true and reo_property maintenance_expense_amount is eq 0 or null' do
        before do
          loan_general.stub(:loan_purpose) {build_stubbed(:loan_purpose, loan_type: "Refinance", property_usage_type: "SecondHome")}
        end

        describe ':occupancy_second_or_investment_and_ins_maint_taxes_not_on_current_housing_expense_then_reo_record_marked_current_must_have_0_for_haz_ins_and_real_est_taxes' do
          before do
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', maintenance_expense_amount: 0, current_residence_indicator: true)] }
            loan_general.stub(:present_housing_expenses) { [build_stubbed(:present_housing_expense, housing_expense_type: 'HazardInsurance', payment_amount: 0)] }
            subject.occupancy_second_or_investment_and_ins_maint_taxes_not_on_current_housing_expense_then_reo_record_marked_current_must_have_0_for_haz_ins_and_real_est_taxes 
          end

          it 'otherwise should not return any messages' do
            expect(subject.errors).to be_empty
          end
        end
      end
    end

    describe ':occupancy_second_or_investment_requires_p_and_i_be_equal_to_monthly_pmnt' do
      context 'and reo_property current_residence_indicator is true' do
        before do
          loan_general.stub(:loan_purpose) {build_stubbed(:loan_purpose, loan_type: "Refinance", property_usage_type: "SecondHome")}
          loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', lien_installment_amount: 1000, current_residence_indicator: true)] }
          loan_general.stub(:borrowers) { [build_stubbed(:borrower, borrower_id: 'BRW1'), build_stubbed(:borrower, borrower_id: 'BRW2')] }
        end

        context 'and present_housing_expense housing_expense_type eq "FirstMortgagePrincipalAndInterest" and payment_amount is > 0' do
          before do
            loan_general.stub(:present_housing_expenses) { [build_stubbed(:present_housing_expense, housing_expense_type: 'FirstMortgagePrincipalAndInterest', payment_amount: 3000, borrower_id: 'BRW1')] }
          end

          context 'and liability type HELOC payment_amount not eq "FirstMortgagePrincipalAndInterest" payment_amount' do
            before do 
              loan_general.stub(:liabilities) {[build_stubbed(:liability, liability_type: 'HELOC', monthly_payment_amount: 100, reo_id: 'R1', borrower_id: 'BRW1'),build_stubbed(:liability, liability_type: 'MortgageLoan', monthly_payment_amount: 100, reo_id: 'R2')]}
              subject.occupancy_second_or_investment_requires_p_and_i_be_equal_to_monthly_pmnt
            end

            it 'should return a warning message' do
              expect(subject.errors).to eq ['Current residence first mortgage payment on housing expense does not match payment amount for mortgage in liabilities.']
            end
          end

          context 'and liability type HELOC payment_amount not eq "FirstMortgagePrincipalAndInterest" payment_amount' do
            before do 
              loan_general.stub(:liabilities) {[build_stubbed(:liability, liability_type: 'HELOC', monthly_payment_amount: 1500, reo_id: 'R1', borrower_id: 'BRW1'),build_stubbed(:liability, liability_type: 'MortgageLoan', monthly_payment_amount: 1500, reo_id: 'R2')]}
              loan_general.stub(:present_housing_expenses) { [build_stubbed(:present_housing_expense, housing_expense_type: 'FirstMortgagePrincipalAndInterest', payment_amount: 3000, borrower_id: 'BRW1'), build_stubbed(:present_housing_expense, housing_expense_type: 'OtherMortgageLoanPrincipalAndInterest', payment_amount: 3000)] }
              subject.occupancy_second_or_investment_requires_p_and_i_be_equal_to_monthly_pmnt
            end

            it 'should return a warning message' do
              expect(subject.errors).to eq ['Current residence first mortgage payment on housing expense does not match payment amount for mortgage in liabilities.']
            end
          end

          context 'and reo_id is R2' do
            before do 
              loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R2', lien_installment_amount: 1000, current_residence_indicator: true, borrower_id: 'BRW1')] }
              loan_general.stub(:liabilities) {[build_stubbed(:liability, liability_type: 'HELOC', monthly_payment_amount: 100, reo_id: 'R1', borrower_id: 'BRW2'),build_stubbed(:liability, liability_type: 'MortgageLoan', monthly_payment_amount: 75, reo_id: 'R1', borrower_id: 'BRW1')]}
              subject.occupancy_second_or_investment_requires_p_and_i_be_equal_to_monthly_pmnt
            end

            it 'should not return any messages' do
              expect(subject.errors).to eq ['Current residence first mortgage payment on housing expense does not match payment amount for mortgage in liabilities.']
            end
          end

          context 'and liability type HELOC and MortgageLoan payment_amount is eq "FirstMortgagePrincipalAndInterest" payment_amount' do
            before do 
              loan_general.stub(:liabilities) {[build_stubbed(:liability, liability_type: 'HELOC', monthly_payment_amount: 1000, reo_id: 'R1', borrower_id: 'BRW1'),build_stubbed(:liability, liability_type: 'MortgageLoan', monthly_payment_amount: 2000, reo_id: 'R1', borrower_id: 'BRW1')]}
              subject.occupancy_second_or_investment_requires_p_and_i_be_equal_to_monthly_pmnt
            end

            it 'should not return any messages' do
              expect(subject.errors).to be_empty
            end
          end

          context 'and liability type HELOC and MortgageLoan payment_amount is eq "FirstMortgagePrincipalAndInterest" + "OtherMortgageLoanPrincipalAndInterest" payment_amount' do
            before do 
              loan_general.stub(:liabilities) {[build_stubbed(:liability, liability_type: 'HELOC', monthly_payment_amount: 2000, reo_id: 'R1'),build_stubbed(:liability, liability_type: 'MortgageLoan', monthly_payment_amount: 4000, reo_id: 'R1')]}
              loan_general.stub(:present_housing_expenses) { [build_stubbed(:present_housing_expense, housing_expense_type: 'FirstMortgagePrincipalAndInterest', payment_amount: 3000), build_stubbed(:present_housing_expense, housing_expense_type: 'OtherMortgageLoanPrincipalAndInterest', payment_amount: 3000)] }
              subject.occupancy_second_or_investment_requires_p_and_i_be_equal_to_monthly_pmnt
            end

            it 'should not return any messages' do
              expect(subject.errors).to be_empty
            end
          end
        end
      end
    end

    describe ':occupancy_second_or_investment_requires_total_of_first_mort_and_other_financing_be_equal_mort_pmnts_on_reo' do
      context 'and reo_property current_residence_indicator is true' do
        before do
          loan_general.stub(:loan_purpose) {build_stubbed(:loan_purpose, loan_type: "Refinance", property_usage_type: "SecondHome")}
          loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', lien_installment_amount: 1000, current_residence_indicator: true)] }
        end

        context 'then present_housing_expense housing_expense_type "FirstMortgagePrincipalAndInterest" and "OtherMortgageLoanPrincipalAndInterest" payment_amounts must equal reo_property lien_installment_amount' do
          describe 'amounts not equal' do
            before do 
              loan_general.stub(:present_housing_expenses) { 
                [
                  build_stubbed(:present_housing_expense, housing_expense_type: 'FirstMortgagePrincipalAndInterest', payment_amount: 100), 
                  build_stubbed(:present_housing_expense, housing_expense_type: 'OtherMortgageLoanPrincipalAndInterest', payment_amount: 100)
                ] 
              }
              subject.occupancy_second_or_investment_requires_total_of_first_mort_and_other_financing_be_equal_mort_pmnts_on_reo
            end

            it 'should return a warning message' do
              expect(subject.errors).to eq ['Mortgage payments entered in housing expense for current residence do not equal mortgage payments entered in  REO for current residence.']
            end
          end

          describe 'amounts are equal' do
            before do 
              loan_general.stub(:present_housing_expenses) { 
                [
                  build_stubbed(:present_housing_expense, housing_expense_type: 'FirstMortgagePrincipalAndInterest', payment_amount: 500), 
                  build_stubbed(:present_housing_expense, housing_expense_type: 'OtherMortgageLoanPrincipalAndInterest', payment_amount: 500)
                ] 
              }
              subject.occupancy_second_or_investment_requires_total_of_first_mort_and_other_financing_be_equal_mort_pmnts_on_reo
            end

            it 'should not return any messages' do
              expect(subject.errors).to be_empty
            end
          end
        end
      end
    end

    # context 'and loan_purpose property_usage_type is Investor and loan_purpose type is "Refinance" and liability either HELOC or Mortgage' do
    #   before do 
    #     loan_general.stub(:loan_purpose) {build_stubbed(:loan_purpose, property_usage_type: "Investor", loan_type: "Refinance")}
    #     loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1')] }
    #     loan_general.stub(:liabilities) {[build_stubbed(:liability, liability_type: 'HELOC', subject_loan_resubordination_indicator: true, reo_id: 'R1'),
    #                                       build_stubbed(:liability, liability_type: 'HELOC', reo_id: 'R1'),
    #                                       build_stubbed(:liability, liability_type: 'MortgageLoan', subject_loan_resubordination_indicator: true, reo_id: 'R1')]}
    #   end
        
    #   describe ':occupancy_second_or_investment_and_purpose_refinance_requires_liability_assoc_to_reo_to_have_subject_property_checked' do
    #     before do 
    #       subject.occupancy_second_or_investment_and_purpose_refinance_requires_liability_assoc_to_reo_to_have_subject_property_checked
    #     end

    #     it 'should require reo_property subject_indicator to be on' do
    #       clean_loan.errors[:warning].count.should eq(1)
    #       clean_loan.errors[:warning][0][1].should eq('Subject property flag is not checked on mortgage/heloc record in the liabilities screen.')
    #     end
    #   end

    #   context 'and reo_property subject_indicator is on' do
    #     before do
    #       loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', subject_indicator: true)] }
    #       subject.occupancy_second_or_investment_and_purpose_refinance_requires_liability_assoc_to_reo_to_have_subject_property_checked
    #     end

    #     it 'should not return errors' do
    #       clean_loan.errors[:warning].count.should eq(0)
    #     end
    #   end
    # end

    describe ':occupancy_investment_and_purpose_refinance_requires_liability_assoc_to_reo_to_have_property_lien_checked' do
      context 'and loan_purpose property_usage_type is Investor and loan_purpose type is "Refinance" and liability either HELOC or Mortgage' do
        before do 
          loan_general.stub(:loan_purpose) {build_stubbed(:loan_purpose, property_usage_type: "Investor", loan_type: "Refinance")}
          loan_general.stub(:liabilities) {[build_stubbed(:liability, liability_type: 'HELOC', subject_loan_resubordination_indicator: true, reo_id: 'R1'),
                                            build_stubbed(:liability, liability_type: 'HELOC', reo_id: 'R1'),
                                            build_stubbed(:liability, liability_type: 'MortgageLoan', subject_loan_resubordination_indicator: true, reo_id: 'R1')]}
        end
          
        context 'and reo_property subject_indicator is on' do
          describe ':occupancy_investment_and_purpose_refinance_requires_liability_assoc_to_reo_to_have_property_lien_checked' do
            before do 
              loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', subject_indicator: true)] }
              subject.occupancy_investment_and_purpose_refinance_requires_liability_assoc_to_reo_to_have_property_lien_checked
            end

            it 'should require disposition_status_type be RetainForRental' do
              expect(subject.errors).to eq ['Rental property flag is not checked on mortgage/heloc for the subject property record in the liabilities screen.']
            end
          end

          describe ':occupancy_investment_and_purpose_refinance_requires_liability_assoc_to_reo_to_have_property_lien_checked' do
            before do 
              loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', subject_indicator: true, disposition_status_type: 'RetainForRental')] }
              subject.occupancy_investment_and_purpose_refinance_requires_liability_assoc_to_reo_to_have_property_lien_checked
            end

            it 'should not return errors' do
              expect(subject.errors).to be_empty
            end
          end
        end
      end
    end

    describe ':occupancy_investment_and_purpose_refinance_requires_reo_record_to_have_property_disposition_of_rental' do
      context 'and loan_purpose property_usage_type is Investor and loan_purpose type is "Refinance" and reo_property subject_indicator eq true' do
        before do
          loan_general.stub(:loan_purpose) {build_stubbed(:loan_purpose, property_usage_type: "Investor", loan_type: "Refinance")}
        end

        describe ':occupancy_investment_and_purpose_refinance_requires_reo_record_to_have_property_disposition_of_rental' do
          before do
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', subject_indicator: true)] }
            subject.occupancy_investment_and_purpose_refinance_requires_reo_record_to_have_property_disposition_of_rental
          end

          it 'should require reo_property disposition_status_type eql "RetainForRental"' do
            expect(subject.errors).to eq ['Subject property is not marked as rental in the REO tab of 1003.']
          end
        end

        context 'and reo_id is not R1' do
          before do 
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R2', subject_indicator: true, disposition_status_type: "RetainForRental")] }
          end

          describe ':occupancy_investment_and_purpose_refinance_requires_reo_record_to_have_property_disposition_of_rental' do
            before { subject.occupancy_investment_and_purpose_refinance_requires_reo_record_to_have_property_disposition_of_rental }

            it 'should not return errors' do
              expect(subject.errors).to be_empty
            end
          end
        end

        context 'and reo_property disposition_status_type eql "RetainForRental"' do
          describe ':occupancy_investment_and_purpose_refinance_requires_reo_record_to_have_property_disposition_of_rental' do
            before do 
              loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', subject_indicator: true, disposition_status_type: "RetainForRental")] }
              subject.occupancy_investment_and_purpose_refinance_requires_reo_record_to_have_property_disposition_of_rental
            end

            it 'should not return errors' do
              expect(subject.errors).to be_empty
            end
          end
        end
      end
    end    

    describe ':occupancy_investment_or_primary_with_more_than_one_unit_requires_subject_property_net_cash_flow_be_gt_0' do
      context 'and loan_purpose property_usage_type is Investor or PrimaryResidence' do
        before do
          loan_general.stub(:loan_purpose) {build_stubbed(:loan_purpose, property_usage_type: "PrimaryResidence")}
          loan_general.stub(:transmittal_datum) { build_stubbed(:transmittal_datum, au_engine_type: "DU") }
          clean_loan.stub(:property) {build_stubbed(:property, num_of_units: 2)}
        end
            
        context 'and current_income income_type = "SubjectPropertyNetCashFlow"' do
          before do 
            loan_general.stub(:current_incomes) {[build_stubbed(:current_income, income_type: 'SubjectPropertyNetCashFlow', monthly_total_amount: 0)]}
            subject.occupancy_investment_or_primary_with_more_than_one_unit_requires_subject_property_net_cash_flow_be_gt_0
          end

          it 'should require current_income with type SubjectPropertyNetCashFlow monthly_total_amount not be eq 0' do
            expect(subject.errors).to eq ['Subject net cash flow is not completed. If not washing the subject property payment, this field must be completed.']
          end
        end

        context 'and current_income income_type = "SubjectPropertyNetCashFlow" and monthly_total_amount gt 0' do
          before do 
            loan_general.stub(:current_incomes) {[build_stubbed(:current_income, income_type: 'SubjectPropertyNetCashFlow', monthly_total_amount: 2000)]}
            subject.occupancy_investment_or_primary_with_more_than_one_unit_requires_subject_property_net_cash_flow_be_gt_0
          end

          it 'should not return errors' do
            expect(subject.errors).to be_empty
          end
        end

        context 'and current_income income_type = "SubjectPropertyNetCashFlow" and monthly_total_amount lt 0' do
          before do 
            loan_general.stub(:current_incomes) {[build_stubbed(:current_income, income_type: 'SubjectPropertyNetCashFlow', monthly_total_amount: -2000)]}
            subject.occupancy_investment_or_primary_with_more_than_one_unit_requires_subject_property_net_cash_flow_be_gt_0
          end

          it 'should not return errors' do
            expect(subject.errors).to be_empty
          end
        end

        context 'and current_income income_type = "SubjectPropertyNetCashFlow" and monthly_total_amount lt 0 and transmittal_datum au_engine_type is "LP"' do
          before do 
            loan_general.stub(:transmittal_datum) { build_stubbed(:transmittal_datum, au_engine_type: "LP") }
            loan_general.stub(:current_incomes) {[build_stubbed(:current_income, income_type: 'SubjectPropertyNetCashFlow', monthly_total_amount: -2000)]}
            subject.occupancy_investment_or_primary_with_more_than_one_unit_requires_subject_property_net_cash_flow_be_gt_0
          end

          it 'should not return errors' do
            expect(subject.errors).to be_empty
          end
        end
      end
    end

    describe ':reo_record_has_property_disposition_of_retained_requires_net_rental_income_be_0_or_null' do
      context 'and reo_property disposition_status_type eql RetainForPrimaryOrSecondaryResidence and rental_income_net_amount gt 0' do
        describe 'rental_income_net_amount not 0' do
          before do 
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', rental_income_net_amount: 2500, disposition_status_type: "RetainForPrimaryOrSecondaryResidence")] }
            subject.reo_record_has_property_disposition_of_retained_requires_net_rental_income_be_0_or_null
          end

          it 'should return an error' do
            expect(subject.errors).to eq ['There is a retained REO entered with rental income. Correct either rental income amount or property disposition.']
          end
        end

        describe 'and reo_id is not R1' do
          before do 
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R2', rental_income_net_amount: 2500, disposition_status_type: "RetainForPrimaryOrSecondaryResidence")] }
            subject.reo_record_has_property_disposition_of_retained_requires_net_rental_income_be_0_or_null
          end

          it 'should not return errors' do
            expect(subject.errors).to eq ['There is a retained REO entered with rental income. Correct either rental income amount or property disposition.']
          end
        end

        describe 'and rental_income_net_amount is null' do
          before do 
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', rental_income_net_amount: nil, disposition_status_type: "RetainForPrimaryOrSecondaryResidence")] }
            subject.reo_record_has_property_disposition_of_retained_requires_net_rental_income_be_0_or_null
          end

          it 'should not return errors' do
            expect(subject.errors).to be_empty
          end
        end
      end
    end
      
    describe ':occupancy_primary_or_secondary_and_purpose_refinance_requires_reo_record_marked_as_subject_or_both_be_marked_as_retained' do
      context 'and loan_purpose property_usage_type is PrimaryResidence or SecondHome' do
        context 'and loan_purpose type is "Refinance" and reo_property subject_indicator eq true' do
          before do 
            loan_general.stub(:loan_purpose) {build_stubbed(:loan_purpose, property_usage_type: "PrimaryResidence", loan_type: "Refinance")}
            loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', subject_indicator: true)] }
          end
            
          describe 'reo_property disposition_status_type not set' do
            before { subject.occupancy_primary_or_secondary_and_purpose_refinance_requires_reo_record_marked_as_subject_or_both_be_marked_as_retained }

            it 'should require reo_property disposition_status_type eql "RetainForPrimaryOrSecondaryResidence"' do
              expect(subject.errors).to eq ['REO record for subject property must be marked retained']
            end
          end

          describe 'and reo_id is not "R1"' do
            before do
              loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', subject_indicator: true)] }
              subject.occupancy_primary_or_secondary_and_purpose_refinance_requires_reo_record_marked_as_subject_or_both_be_marked_as_retained
            end

            it 'should require reo_property disposition_status_type eql "RetainForPrimaryOrSecondaryResidence"' do
              expect(subject.errors).to eq ['REO record for subject property must be marked retained']
            end
          end

          describe 'and reo_property disposition_status_type eql "RetainForPrimaryOrSecondaryResidence"' do
            before do
              loan_general.stub(:reo_properties) { [build_stubbed(:reo_property, reo_id: 'R1', subject_indicator: true, disposition_status_type: "RetainForPrimaryOrSecondaryResidence")] }
              subject.occupancy_primary_or_secondary_and_purpose_refinance_requires_reo_record_marked_as_subject_or_both_be_marked_as_retained
            end

            it 'should not return errors' do
              expect(subject.errors).to be_empty
            end
          end
        end
      end    
    end

  end
end
