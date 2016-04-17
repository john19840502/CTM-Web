require 'servicing/card_deck_builder'
require 'fi_serv_loan'
require 'spec_helper' #you can get rid of this if you get rid of references to Master::Loan

describe Servicing::CardDeckBuilder do

  let(:loan) { Master::Loan.new }
  let(:translator) { FakeTranslator.new loan }
  let(:builder) { Servicing::CardDeckBuilder.new translator }
  let(:deck) { builder.card_deck }
  let(:primary_borrower) { build_fake_borrower borrower_id: 'BRW1' }
  let(:secondary_borrower) { build_fake_borrower borrower_id: 'BRW2' }
  let(:tertiary_borrower) { build_fake_borrower borrower_id: 'BRW3', first_name: 'Borrower', last_name: 'Three', middle_name: 'OMGHI', suffix: 'JR', ssn: '123 12 1234'}

  before do
    #this is dumb but I don't know how else to set it up
    brws = [primary_borrower, secondary_borrower, tertiary_borrower]
    brws.stub primary: primary_borrower
    brws.stub secondary: secondary_borrower
    loan.stub borrowers: brws
    loan.stub coborrowers: [tertiary_borrower]

    hud_lines = []
    hud_lines.stub(:hud) { hud_lines.select{|line| line.hud_type == 'HUD'}}
    hud_lines.stub(:gfe) { hud_lines.select{|line| line.hud_type == 'GFE'}}
    loan.stub hud_lines: hud_lines
    loan.stub(:escrow_coverage_amount).and_return('123.12')
    loan.stub(:is_fha?).and_return(true)
    loan.stub(:lowest_fico_score).and_return(800)

    shippings = []
    loan.stub shippings: shippings

    liabilities = []
    loan.stub liabilities: liabilities

    legal_descriptions = []
    loan.stub legal_descriptions: legal_descriptions

    escrow_disbursements = []
    loan.stub escrow_disbursements: escrow_disbursements

    proposed_housing_expenses = []
    loan.stub proposed_housing_expenses: proposed_housing_expenses

    down_payments = []
    loan.stub down_payments: down_payments

    loan.stub rep_properties: []
    loan.stub has_mi?: true
    loan.stub trid_loan?: false

    loan.original_ltv = 90

    HpmlResult.stub(:for) { false }
  end


  describe "fields" do

    it 'flood_zone' do
      loan.stub flood_determination_nfip_flood_zone_identifier: "500"
      deck.flood_zone.should == '   '
    end

    it 'flood_zone' do
      loan.stub flood_determination_nfip_flood_zone_identifier: "*ab"
      deck.flood_zone.should == ' ab'
      deck.flood_loma_lomr_received.should == 'N'
    end

    it 'flood_loma_lomr_received' do
      loan.stub flood_determination_nfip_flood_zone_identifier: "NONE"
      deck.flood_loma_lomr_received.should == ' '
    end

    it 'flood_loma_lomr_received' do
      loan.stub flood_determination_nfip_flood_zone_identifier: ""
      deck.flood_loma_lomr_received.should == ' '
    end

    it 'flood_loma_lomr_received' do
      loan.stub flood_determination_nfip_flood_zone_identifier: nil
      deck.flood_loma_lomr_received.should == ' '
    end

    it "loan_num" do
      loan.stub loan_num: '1234567'
      deck.loan_num.should include '1234567'
    end

    it "servicer loan_num -- blank for now" do
      loan.stub loan_num: '1234567'
      deck.servicer_loan_num.should == "1234567             "
    end

    it "principal balance" do
      loan.stub principal_balance: 233455.75
      deck.principal_balance.should include '23345575'
    end

    it "loan_type" do
      translator.stub loan_type_number: 9
      deck.loan_type.should include '9'
    end

    it 'loan_subtype' do
      loan.stub(:loan_amortization_type).and_return('Normal')
      deck.loan_subtype.should == '0'
    end

    describe 'Arms' do
      it 'loan_subtype' do
        loan.stub(:loan_amortization_type).and_return('AdjustableRate')
        deck.loan_subtype.should == '8'
      end
    end


    it 'ami indicator' do
      translator.stub alternative_mortgage_indicator: '5'
      deck.alternative_mortgage_indicator.should == '5'
    end

    it "distribution sequence pointer" do
      deck.distribution_sequence_pointer.should == '7'
    end

    it "primary collateral code" do
      deck.primary_collateral_code.should == '5'
    end

    it "paid to date" do
      loan.stub first_payment_on: DateTime.new(2013, 1, 2, 12, 34, 56)
      deck.paid_to_date.should include '121202'
    end

    describe "note_rate" do
      it "should be the final note rate when that is present" do
        loan.stub final_note_rate: 3.45
        deck.note_rate.should include '345'
        deck.market_rate.should include '345'
      end

      [0, nil].each do |fr|
        it "should be the requested rate when final rate is #{fr || 'nil'}" do
          loan.stub final_note_rate: fr
          loan.stub requested_interest_rate_percent: 3.45
          deck.note_rate.should include '345'
          deck.market_rate.should include '345'
        end
      end
    end

    it "pi_pmt" do
      loan.stub principal_and_interest_payment: 55655.23
      deck.pi_pmt.should == '00005565523'
    end

    describe "condo name" do
      before { loan.project_name = 'Northgate Apts' }

      it "should be empty if gse prop type not condo" do 
        loan.gse_property_type = 'SomeOther'
        deck.condo_name.should == '                                                            '
      end

      it "should be Northgate Apts if gse prop type is condo" do 
        loan.gse_property_type = 'DetachedCondominium'
        deck.condo_name.should start_with loan.project_name
      end

      it "should not get set if the condo name is nil" do
        loan.gse_property_type = "DetachedCondominium"
        loan.project_name = nil
        # Fiserv::CardDeck.any_instance.should_not_receive(:"condo_name=")
        deck.condo_name.should == '                                                            '
      end

      it "should remove all / from the project name" do
        loan.gse_property_type = "DetachedCondominium"
        loan.project_name = "ThisIs/Project/Name"
        projName = "ThisIsProjectName"
        deck.condo_name.should start_with projName
      end
    end

    it "investor loan num" do
      loan.stub loan_num: 8888888
      deck.investor_loan_num.should == '8888888        '
    end

    describe "investor rate" do
      it "should be the final note rate when that is present" do
        loan.stub final_note_rate: 3.45
        deck.investor_rate.should include '345'
      end

      [0, nil].each do |fr|
        it "should be the requested rate when final rate is #{fr || 'nil'}" do
          loan.stub final_note_rate: fr
          loan.stub requested_interest_rate_percent: 3.45
          deck.investor_rate.should include '345'
        end
      end
    end

    it 'next_billing_date_monthly' do
      deck.next_billing_date_monthly.should == "00000"
    end

    it "property_type_code" do
      translator.stub property_type: 72
      deck.property_type_code.should == '072'
    end

    it "purpose_code" do
      translator.stub purpose: 13
      deck.purpose_code.should == '013'
    end

    it "pmi_case_num_prefix" do
      translator.stub pmi_company_code: 'FH'
      deck.pmi_case_num_prefix.should == 'FH'
    end

    describe "pmi_case_num" do
      context 'VA' do
      end
      context 'FHA' do
        before { loan.mortgage_type = 'FHA' }
        it "should munge the agency case identifier" do
          loan.agency_case_identifier = "264-0682118-703"
          deck.pmi_case_num.should == "264068211703"
        end
        it "should not die if the aci is blank" do
          loan.agency_case_identifier = ""
          deck.pmi_case_num.should == "000000000000"
        end
        it "should not die if the aci for some reason has less than 10 chars" do
          loan.agency_case_identifier = "123456"
          deck.pmi_case_num.should == "000000123456"
        end
      end

      context 'FarmersHomeAdministration' do
        before { loan.mortgage_type = 'FarmersHomeAdministration' }
        it "should munge the agency case identifier" do
          loan.agency_case_identifier = "264-0682118-70"
          deck.pmi_case_num.should == "264068211870"
        end
        it "should not die if the aci is blank" do
          loan.agency_case_identifier = ""
          deck.pmi_case_num.should == "000000000000"
        end
        it "should not die if the aci for some reason has less than 10 chars" do
          loan.agency_case_identifier = "123456"
          deck.pmi_case_num.should == "000000123456"
        end
      end

      context 'VA' do
        before { loan.mortgage_type = 'VA' }
        it "should munge the agency case identifier" do
          loan.agency_case_identifier = "264-0682118-3"
          deck.pmi_case_num.should == "026406821183"
        end
        it "should not die if the aci is blank" do
          loan.agency_case_identifier = ""
          deck.pmi_case_num.should == "000000000000"
        end
        it "should not die if the aci for some reason has less than 10 chars" do
          loan.agency_case_identifier = "123456"
          deck.pmi_case_num.should == "000000123456"
        end
      end
      # ["FHA", "FarmersHomeAdministration", "VA"].each do |mt|
      #   context "when the mortgage type is #{mt}" do
      #     before { loan.mortgage_type = mt }
      #     it "should munge the agency case identifier" do
      #       loan.agency_case_identifier = "264-0682118-703"
      #       deck.pmi_case_num.should == "264068211703"
      #     end
      #     it "should not die if the aci is blank" do
      #       loan.agency_case_identifier = ""
      #       deck.pmi_case_num.should == "000000000000"
      #     end
      #     it "should not die if the aci for some reason has less than 10 chars" do
      #       loan.agency_case_identifier = "123456"
      #       deck.pmi_case_num.should == "000000123456"
      #     end
      #   end
      # end

      it "conventional loans with mi use mi cert id" do
        loan.mortgage_type = 'Conventional'
        loan.stub has_mi?: true
        loan.mi_certificate_id = 123456789
        deck.pmi_case_num.should == '000123456789'
      end

      it "conventional loans with no mi use blank" do
        loan.mortgage_type = 'Conventional'
        loan.stub has_mi?: false
        loan.mi_certificate_id = 123456789
        deck.pmi_case_num.should == '000000000000'
      end

      it "other loans leave blank" do
        loan.mortgage_type = 'Other'
        loan.stub has_mi?: true
        loan.mi_certificate_id = 123456789
        deck.pmi_case_num.should == '000123456789'
      end
    end

    describe "fha status" do
      it "should be blank when mortgage type is FHA" do
        loan.stub mortgage_type: 'FHA'
        deck.fha_235_status.should == ' '
      end

      it "should be blank otherwise" do
        ['SDFLKJ', nil, ''].each do |type|
          loan.stub mortgage_type: type
          deck.fha_235_status.should == ' '
        end
      end
    end

    describe "prepayment_disclosure_option_code" do
      it "should be B when mortgage type is FHA" do
        loan.stub mortgage_type: 'FHA'
        deck.prepayment_disclosure_option_code.should == 'B'
      end

      it "should be blank otherwise" do
        ['SDFLKJ', nil, '', 'Conventional'].each do |type|
          loan.stub mortgage_type: type
          deck.prepayment_disclosure_option_code.should == ' '
        end
      end
    end

    it 'user_field_43' do
      loan.stub last_submitted_au_recommendation: 'EA-I/Ineligible'
      deck.user_field_43.should == 'EA1'
    end

    it 'user_field_43' do
      deck.user_field_43.should == '   '
    end

    describe 'pmi_rate' do
      before do
        premium = Master::MiRenewalPremium.new({rate:2.345}, without_protection: true)
        loan.stub first_mi_renewal_premium: premium
        loan.stub fha_coverage_renewal_rate: 3.456
      end
      context "for conventional loans" do
        before { loan.mortgage_type = 'Conventional' }
        it "should be the first_mi_renewal_premium" do
          deck.pmi_rate.should == '0234500'
        end
      end
      context "for FHA loans" do
        before { loan.mortgage_type = 'FHA' }
        it "should be the fha_coverage_renewal_rate" do
          deck.pmi_rate.should == '0345600'
        end
      end
      context "for FarmersHomeAdministration loans" do
        before { 
          loan.mortgage_type = 'FarmersHomeAdministration' 
          loan.stub closing_on: Date.new(2012, 2, 23)
        }
        it "should be 2.00" do
          deck.pmi_rate.should == '0040000'
        end
      end
      context "for other loans" do
        before { loan.mortgage_type = 'Other' }
        it "should be blank" do
          deck.pmi_rate.should == '0000000'
        end
      end
    end

    describe 'dti - user_field_47' do

      it 'with total ratio in calculations' do
        loan.stub_chain(:calculations, :total_obligation_ratio).and_return(21.231)
        deck.user_field_47.should == "21.231         "
      end

      it 'when empty' do
        loan.stub(:dti).and_return(nil)
        deck.user_field_47.should == "0              "
      end
    end

    it 'user_field_51' do
      deck.user_field_51.should == "                                   "
    end

    describe "mip_status_code" do
      context "for FHA loans" do
        before { loan.mortgage_type = "FHA" }
        it { deck.mip_status_code.should == 'A ' }
      end
      context "for other loans" do
        before { loan.mortgage_type = "Conventional" }
        it { deck.mip_status_code.should == '  ' }
      end
    end

    describe "hud_base_loan_amount" do
      before { loan.base_loan_amount = 12345.67 }

      context "for FHA loans" do
        before { loan.mortgage_type = "FHA" }
        it "should be the base loan amount" do
          deck.hud_base_loan_amount.should == '001234567'
        end
      end
      context "for other loans" do
        before { loan.mortgage_type = "Conventional" }
        it { deck.hud_base_loan_amount.should == '000000000' }
      end
    end

    describe "hud_mi_term_years" do
      before { loan.original_mi_period_months = 365 }

      context "for FHA loans" do
        before { loan.mortgage_type = "FHA" }

        context "when LTV > 90" do
          before { loan.original_ltv = 91 }
          context "when GFE says less than 30 years" do
            before { loan.term = 29*12 }
            it "should use the GFE term" do
              deck.hud_mi_term_years.should == '029'
            end
          end
          context "when GFE says more than 30 yrs" do
            before { loan.term = 31*12 }
            it "should be 30 years" do
              deck.hud_mi_term_years.should == '030'
            end
          end
        end
        context "when LTV is <= 90" do
          before { loan.original_ltv = 90 }
          context "when GFE says less than 11 years" do
            before { loan.term = 10*12 }
            it "should use the GFE term in years" do
              deck.hud_mi_term_years.should == '010'
            end
          end
          context "when GFE says more than 11 yrs" do
            before { loan.term = 12*12 }
            it "should be 11 years" do
              deck.hud_mi_term_years.should == '011'
            end
          end
        end
      end

      context "for other loans" do
        before { loan.mortgage_type = "Conventional" }
        it { deck.hud_mi_term_years.should == '000' }
      end
    end

    describe "mip_amount_financed" do
      before { loan.mi_and_funding_fee_financed_amount = 4444.55 }

      [ "FHA", "Conventional" ].each do |mortgage_type|
        context "for #{mortgage_type} loans" do
          before { loan.mortgage_type = mortgage_type }
          it { deck.mip_amount_financed.should == '0444455' }
        end
      end
      context "for other loans" do
        before { loan.mortgage_type = "elkjfds" }
        it { deck.mip_amount_financed.should == '0000000' }
      end
    end

    describe "mip_calculation_method" do
      context "for FHA loans" do
        before { loan.mortgage_type = "FHA" }
        it { deck.mip_calculation_method.should == 'SC' }
      end
      context "for other loans" do
        before { loan.mortgage_type = "Conventional" }
        it { deck.mip_calculation_method.should == '  ' }
      end
    end

    describe "mip_stop_date" do
      before do
        loan.original_mi_period_months = 21
        loan.first_payment_on = Date.new(2011, 3, 21)
      end

      context "for FHA loans" do
        before { loan.mortgage_type = "FHA" }
        it { deck.mip_stop_date.should == '1121221' }

        [0, nil].each do |val|
          it "should be zeroes when the MI period months are missing with value #{val}" do
            loan.original_mi_period_months = val
            deck.mip_stop_date.should == '0000000'
          end
        end
      end
      context "for other loans" do
        before { loan.mortgage_type = "Conventional" }
        it { deck.mip_stop_date.should == '0000000' }
      end
    end

    describe "jq fields" do
      before do 
        dp = DownPayment.new({source_description: 'FHLBC DPP', amount: 123}, without_protection: true)

        DownPayment.stub(:fhlbc_dpp).and_return(dp)  
      end

      it "should be the premium from closing amt" do
        deck.jq3.should == '03'
        deck.jq5.should == '00000012300'
      end
    end

    describe "mi_premium_pd_at_closing" do
      context "for conventional loans" do
        before { loan.mortgage_type = "Conventional" }
        it "should be the premium from closing amt" do
          loan.mi_premium_from_closing_amt = 123.45
          deck.mi_premium_pd_at_closing.should == '0012345'
        end
      end
      context "for FHA loans" do
        before { loan.mortgage_type = "FHA" }
        it "should be the upfront FHA premium amount" do
          loan.mi_fha_upfront_premium_amt = 223.45
          deck.mi_premium_pd_at_closing.should == '0022345'
        end
      end
    end

    describe "mi_premium_financed_amt" do
      it "should be the MIAndFundingFeeFinancedAmount" do
        loan.mi_and_funding_fee_financed_amount = 7654.32
        deck.mi_premium_amt_financed.should == "0765432"
      end
    end

    describe "mi_premium_expiration_date" do
      before do
        loan.mortgage_type = "Conventional"
        loan.stub :has_mi? => true
        loan.stub has_mi?: true
        loan.mi_scheduled_termination_date = Date.new(2003, 4, 5)
      end

      it "should not come from scheduled termination date" do
        loan.stub :has_mi? => false
        deck.mi_premium_expiration_date.should_not == "1030405"
      end

      it "should not set a value when the loan is not conventional" do
        loan.mortgage_type = "Something Else"
        deck.mi_premium_expiration_date.should == '0000000'
      end

      it "should not set a value when the loan has no MI" do
        loan.stub has_mi?: false
        deck.mi_premium_expiration_date.should == '0000000'
      end

      it "should not set it when there is no first payment date" do
        loan.amortization_term = 15*12
        loan.final_note_rate = 4.5
        loan.principal_and_interest_payment = 764.99
        loan.purchase_price = 100_000
        loan.property_appraised_amt = 120_000
        loan.first_payment_on = nil

        deck.mi_premium_expiration_date.should == '0000000'
      end

      it "15 year at 4.5% for 100k with 764.99 monthly payment" do
        loan.amortization_term = 15*12
        loan.final_note_rate = 4.5
        loan.first_payment_on = Date.new(2014, 2, 1)
        loan.principal_and_interest_payment = 764.99
        loan.purchase_price = 100_000
        loan.property_appraised_amt = 120_000

        expect(deck.mi_premium_expiration_date).to eql("1180501")
      end

      it "30 year at 4% for 120k with 477.42 monthly payment" do
        loan.amortization_term = 30*12
        loan.final_note_rate = 4
        loan.first_payment_on = Date.new(2014, 6, 1)
        loan.principal_and_interest_payment = 477.42
        loan.purchase_price = 120_000
        loan.property_appraised_amt = 130_000

        expect(deck.mi_premium_expiration_date).to eql("1171101")
      end

      it "30 year at 4% appraised for 120k sold for 160k with 716.12 monthly payment" do
        loan.amortization_term = 30*12
        loan.final_note_rate = 4
        loan.first_payment_on = Date.new(2014, 6, 1)
        loan.principal_and_interest_payment = 716.12
        loan.purchase_price = 160_000
        loan.property_appraised_amt = 120_000

        expect(deck.mi_premium_expiration_date).to eql("1300201")
      end

      it "should not be set when has_mi? is false" do
        loan.amortization_term = 30*12
        loan.final_note_rate = 4
        loan.first_payment_on = Date.new(2014, 6, 1)
        loan.principal_and_interest_payment = 716.12
        loan.purchase_price = 160_000
        loan.property_appraised_amt = 120_000
        loan.stub :has_mi? => false

        deck.mi_premium_expiration_date.should == '0000000'
      end

    end

    describe "mi_premium_term" do
      context "for a conventional loan with mi" do
        before do 
          loan.mortgage_type = 'Conventional'
          loan.stub :has_mi? => true
        end

        it "15 year at 4.5% for 100k with 764.99 monthly payment" do
          loan.amortization_term = 15*12
          loan.final_note_rate = 4.5
          loan.first_payment_on = Date.new(2014, 2, 1)
          loan.principal_and_interest_payment = 764.99
          loan.purchase_price = 100_000
          loan.property_appraised_amt = 120_000
  
          expect(deck.mi_premium_term).to eql('051')
        end
  
        it "30 year at 4% for 120k with 477.42 monthly payment" do
          loan.amortization_term = 30*12
          loan.final_note_rate = 4
          loan.first_payment_on = Date.new(2014, 6, 1)
          loan.principal_and_interest_payment = 477.42
          loan.purchase_price = 120_000
          loan.property_appraised_amt = 130_000
  
          expect(deck.mi_premium_term).to eql('041')
        end
  
        it "30 year at 4% appraised for 120k sold for 160k with 716.12 monthly payment" do
          loan.amortization_term = 30*12
          loan.final_note_rate = 4
          loan.first_payment_on = Date.new(2014, 6, 1)
          loan.principal_and_interest_payment = 716.12
          loan.purchase_price = 160_000
          loan.property_appraised_amt = 120_000
  
          expect(deck.mi_premium_term).to eql('188')
        end
      end

      context "for a conventional loan with no mi" do
        before do
          loan.mortgage_type = 'FHA'
          loan.stub :has_mi? => false
        end

        it "should come from loan" do
          loan.mi_initial_premium_term_months = 123
          loan.amortization_term = 456
          deck.mi_premium_term.should == '456'
        end
      end

      context "for other loan types" do
        before { loan.mortgage_type = 'FHA' }

        it "should come from loan" do
          loan.mi_initial_premium_term_months = 123
          loan.amortization_term = 456
          deck.mi_premium_term.should == '456'
        end
      end
    end

    it "closing_date" do
      loan.stub closing_on: Date.new(2012, 2, 23)
      deck.closing_date.should == '1120223'
    end

    it "original_balance" do
      loan.stub original_balance: 123.45
      deck.original_balance.should == '00000012345'
    end

    it "appraisal_date" do
      loan.appraised_on = Date.new(1999, 8, 31)
      deck.appraisal_date.should == '19908'
    end

    it "appraisal_value" do
      loan.stub property_appraised_amt: 12345.67
      deck.appraisal_value.should == '000012346'
    end

    it "sale_price" do
      loan.stub purchase_price: 123456.78
      deck.sale_price.should == '000123457'
    end

    it "maturity_date" do
      loan.stub mature_on: Date.new(2013, 5, 31)
      deck.maturity_date.should == '11305'
    end

    it "year_built" do
      loan.stub structure_built_year: 2011
      deck.year_built.should == '02011'
    end

    it "term" do
      loan.amortization_term = 123
      deck.amortization_term.should == '123'
    end

    it "num_units" do
      loan.stub number_of_units: 11
      deck.num_units.should == '011'
    end

    it "state_code" do
      translator.stub state_code: '878'
      deck.state_code.should == '878'
    end

    it "census_tract" do
      loan.stub census_tract: 1234.56
      deck.census_tract.should == '0123456'
    end

    it "institution_id" do
      loan.stub institution_id: 123
      deck.institution_id.should == '123  '
    end

    it "receipt_opt should be hardcoded to 7" do
      deck.receipt_opt.should == '7'
    end

    it "key_flag should be hardcoded to B" do
      deck.key_flag.should == 'B'
    end

    it "coupon_expiration hardcode to 00000" do
      deck.coupon_expiration.should == '00000'
    end

    it "property_use_code should be 1" do
      deck.property_use_code.should == '1'
    end

    it "county code" do
      loan.stub county_code: 123
      deck.county_code.should == '123'
    end

    describe "arm_contract_number" do
      context "when it is an ARM loan" do
        before do
          loan.amortization_type = "AdjustableRate" 
          loan.product_code = 'C7/1ARM LIB'
        end
        it "should hardcode" do
          deck.arm_contract_number.should == '624504'
        end
      end
      context "when it is an ARM loan" do
        before do
          loan.amortization_type = "AdjustableRate" 
          loan.product_code = 'C5/1ARM LIB HIBAL'
        end
        it "should hardcode" do
          deck.arm_contract_number.should == '624506'
        end
      end
      context "when it is an ARM loan" do
        before do
          loan.amortization_type = "AdjustableRate" 
          loan.product_code = 'WHOKNOWSWHAT'
        end
        it "should hardcode" do
          deck.arm_contract_number.should == '777777'
        end
      end
      context "when it is a fixed rate loan" do
        before { loan.amortization_type = "Fixed" }
        it "should not be set" do
          Fiserv::CardDeck.any_instance.should_not_receive(:"arm_contract_number=")
          deck
        end
      end
    end

    describe "arm_margin_rate" do
      before { loan.arm_margin_rate = 1.234 }
      context "when it is an ARM loan" do
        before { loan.amortization_type = "AdjustableRate" }
        it "should be the margin rate" do
          deck.arm_margin_rate.should == '0123400'
        end
      end
      context "when it is a fixed rate loan" do
        before { loan.amortization_type = "Fixed" }
        it "should not be set" do
          Fiserv::CardDeck.any_instance.should_not_receive(:"arm_margin_rate=")
          deck
        end
      end
    end

    describe "arm_floor_rate" do
      before { loan.arm_floor_rate = 2.234 }
      context "when it is an ARM loan" do
        before { loan.amortization_type = "AdjustableRate" }
        it "should be the margin rate" do
          deck.arm_floor_rate.should == '0223400'
        end
      end
      context "when it is a fixed rate loan" do
        before { loan.amortization_type = "Fixed" }
        it "should not be set" do
          Fiserv::CardDeck.any_instance.should_not_receive(:"arm_floor_rate=")
          deck
        end
      end
    end

    describe "arm_floor_rate" do
      before { 
        loan.arm_ceiling_rate = 5.321
        loan.rate_adjustment_lifetime_cap_percent = 1.234
        loan.final_note_rate = 1
      }
      context "when it is an ARM loan" do
        before { loan.amortization_type = "AdjustableRate" }
        it "should be the margin rate" do
          deck.arm_ceiling_rate.should == '0223400'
        end
      end
      context "when it is a fixed rate loan" do
        before { loan.amortization_type = "Fixed" }
        it "should not be set" do
          Fiserv::CardDeck.any_instance.should_not_receive(:"arm_ceiling_rate=")
          deck
        end
      end
    end

    describe "arm_original_index_rate" do
      before { loan.base_index_margin = 1.234 }
      context "when it is an ARM loan" do
        before { loan.amortization_type = "AdjustableRate" }
        it "should be the base_index_margin" do
          deck.arm_original_index_rate.should == '0123400'
        end
      end
      context "when it is a fixed rate loan" do
        before { loan.amortization_type = "Fixed" }
        it "should not be set" do
          Fiserv::CardDeck.any_instance.should_not_receive(:"arm_original_index_rate=")
          deck
        end
      end
    end

    describe "arm_original_rate" do
      before { loan.requested_interest_rate_percent = 2.05 }
      context "when it is an ARM loan" do
        before { loan.amortization_type = "AdjustableRate" }

        context "when there is a nonzero final note rate" do
          before { loan.final_note_rate = 3.45 }
          it "should be the final_note_rate" do
            deck.arm_original_rate.should == '0345000'
          end
        end

        context "when there is a zero final note rate" do
          before { loan.final_note_rate = 0 }
          it "should be the requested_interest_rate_percent " do
            deck.arm_original_rate.should == '0205000'
          end
        end

        context "when there is a no final note rate" do
          before { loan.final_note_rate = nil }
          it "should be the requested_interest_rate_percent " do
            deck.arm_original_rate.should == '0205000'
          end
        end
      end
      context "when it is a fixed rate loan" do
        before { loan.amortization_type = "Fixed" }
        it "should not be set" do
          Fiserv::CardDeck.any_instance.should_not_receive(:"arm_original_rate=")
          deck
        end
      end
    end

    describe "arm_p_and_i_pmt" do
      before do
        loan.proposed_housing_expenses <<
          Master::ProposedHousingExpense.new(payment_amount: 123.76, housing_expense_type: 'foo') <<
          Master::ProposedHousingExpense.new(payment_amount: 456.11, housing_expense_type: 'FirstMortgagePrincipalAndInterest')
      end

      context "when it is an ARM loan" do
        before { loan.amortization_type = "AdjustableRate" }
        it "should be the phe for p&i" do
          deck.arm_p_and_i_pmt.should == '00000045611'
        end
      end
      context "when it is a fixed rate loan" do
        before { loan.amortization_type = "Fixed" }
        it "should not be set" do
          Fiserv::CardDeck.any_instance.should_not_receive(:"arm_p_and_i_pmt=")
          deck
        end
      end
    end

    describe "arm_amortization_term" do
      before { loan.amortization_term = 123 }

      context "when it is an ARM loan" do
        before { loan.amortization_type = "AdjustableRate" }
        it "should be the term" do
          deck.arm_amortization_term.should == '123'
        end
      end
      context "when it is a fixed rate loan" do
        before { loan.amortization_type = "Fixed" }
        it "should not be set" do
          Fiserv::CardDeck.any_instance.should_not_receive(:"arm_amortization_term=")
          deck
        end
      end
    end

    describe "arm rate adjustment dates" do
      before do 
        loan.first_rate_adjustment_date = Date.new(2013, 12, 15)
        loan.first_payment_change_date = Date.new(2014, 2, 15)
      end

      context "when it is an ARM loan" do
        before { loan.amortization_type = "AdjustableRate" }
        it "first adjustment date should just be the date" do
          deck.arm_first_rate_adjustment_date.should == '1131215'
        end

        it "next adjustment date should be one month later" do
          deck.arm_next_rate_adjustment_date.should == '1140115'
        end
      end
      context "when it is a fixed rate loan" do
        before { loan.amortization_type = "Fixed" }
        it "should not be set" do
          Fiserv::CardDeck.any_instance.should_not_receive(:"arm_first_rate_adjustment_date=")
          Fiserv::CardDeck.any_instance.should_not_receive(:"arm_next_rate_adjustment_date=")
          deck
        end
      end
    end

    describe "arm_amortization_term" do
      before { loan.amortization_term = 123 }

      context "when it is an ARM loan" do
        before { 
          loan.amortization_type = "AdjustableRate" 
          loan.first_payment_on = Date.new(2015, 1, 15)
          loan.final_note_rate = 0.2
          loan.principal_and_interest_payment = 3000.25
        }
        it "should be the term" do
          deck.gy3.should                     == "1"
          deck.gy4.should                     == "1"
          deck.gy19.should                    == "2"
          deck.gy20.should                    == "1"
          deck.first_payment_on_gy5.should    == '1141215'
          deck.note_rate_gy12.should          == '0020000'
          deck.first_payment_on_gy21.should   == '1150115'
          deck.pi_pmt_gy28.should             == "00000300025"
          deck.gy41.should                    == '0000000'
        end
      end
      context "when it is a fixed rate loan" do
        before { loan.amortization_type = "Fixed" }
        it "should not be set" do
          Fiserv::CardDeck.any_instance.should_not_receive(:"gy3=")
          deck
        end
      end
    end

    describe "rate_term_code" do
      it "should be 1 for fixed rate loans" do
        loan.amortization_type = 'Fixed'
        deck.rate_term_code.should == '1'
      end
      it "should be 3 for ARM loans" do
        loan.amortization_type = 'AdjustableRate'
        deck.rate_term_code.should == '3'
      end
    end

    describe "primary borrower demographic fields" do
      it "primary_borrower_birth_date" do
        primary_borrower.birth_date = Date.new(1985, 3, 21)
        deck.primary_borrower_birth_date.should == "0850321"
      end

      it "primary_borrower_us_citizen_flag for US citizen" do
        primary_borrower.citizenship_type = "USCitizen"
        deck.primary_borrower_us_citizen_flag.should == 'Y'
      end

      it "primary_borrower_us_citizen_flag for non US citizen" do
        primary_borrower.citizenship_type = "Nope"
        deck.primary_borrower_us_citizen_flag.should == 'N'
      end

      it "primary_borrower_years_of_school" do
        primary_borrower.schooling_years = 15
        deck.primary_borrower_years_of_school.should == '15'
      end

      it "primary_borrower_employer_name" do
        primary_borrower.employer.name = 'Acme'
        deck.primary_borrower_employer_name.should == 'Acme' + ' '*21
      end

      it "primary_borrower_position" do
        primary_borrower.employer.position = 'Flunky'
        deck.primary_borrower_position.should == 'Flunky' + ' '*19
      end

      it "primary_borrower_years_at_position" do
        primary_borrower.employer.years_at_position = 2
        deck.primary_borrower_years_at_position.should == '02'
      end

      it "primary_borrower_months_at_position" do
        primary_borrower.employer.months_at_position = 3
        deck.primary_borrower_months_at_position.should == '03'
      end

      it "primary_borrower_years_in_profession" do
        primary_borrower.employer.years_in_profession = 2
        deck.primary_borrower_years_in_profession.should == '02'
      end

      it "primary_borrower_self_employed true" do
        primary_borrower.employer.self_employment_flag = true
        deck.primary_borrower_self_employed.should == 'Y'
      end

      it "primary_borrower_self_employed false" do
        primary_borrower.employer.self_employment_flag = false
        deck.primary_borrower_self_employed.should == 'N'
      end
    end

    describe "primary borrower income fields" do
      before do
        translator.stub primary_borrower_income_of_type: 0
      end

      it "primary_borrower_income_base" do
        translator.stub(:primary_borrower_income_of_type).with("Base").and_return(98765.43)
        deck.primary_borrower_income_base.should == "00009876543"
      end

      it "primary_borrower_income_overtime" do
        translator.stub(:primary_borrower_income_of_type).with("Overtime").and_return(98765.43)
        deck.primary_borrower_income_overtime.should == "00009876543"
      end

      it "primary_borrower commission income" do
        translator.stub(:primary_borrower_income_of_type).with("Commission").and_return(98765.43)
        deck.primary_borrower_income_commission.should == "00009876543"
      end

      it "primary_borrower bonus income" do
        translator.stub(:primary_borrower_income_of_type).with("Bonus").and_return(98765.43)
        deck.primary_borrower_income_bonus.should == "00009876543"
      end

      it "primary_borrower dividend income" do
        translator.stub(:primary_borrower_income_of_type).with("DividendsInterest").and_return(98765.43)
        deck.primary_borrower_income_dividend.should == "00009876543"
      end

      it "primary_borrower rental income" do
        translator.stub(:primary_borrower_income_of_type).with("NetRentalIncome").and_return(98765.43)
        deck.primary_borrower_income_rental.should == "00009876543"
      end

      it "primary_borrower rental income" do
        translator.stub primary_borrower_income_other: 98765.43
        deck.primary_borrower_income_other.should == "00009876543"
      end

      it "primary_borrower total income" do
        translator.stub primary_borrower_total_monthly_income: 98765.43
        deck.primary_borrower_total_income.should == "0000009876543"
      end

      it "income fields should not be shown for employee loans" do
        translator.stub is_employee_loan?: 1
        translator.stub(:primary_borrower_income_of_type).with("Base").and_return(2.22)
        translator.stub(:primary_borrower_income_of_type).with("Overtime").and_return(1.11)
        translator.stub(:primary_borrower_income_of_type).with("Commission").and_return(3.33)
        translator.stub(:primary_borrower_income_of_type).with("Bonus").and_return(4.44)
        translator.stub(:primary_borrower_income_of_type).with("DividendsInterest").and_return(4.44)
        translator.stub(:primary_borrower_income_of_type).with("NetRentalIncome").and_return(5.55)
        translator.stub(:primary_borrower_income_other).and_return(6.66)
        translator.stub(:primary_borrower_total_monthly_income).and_return(7.77)
        deck.primary_borrower_income_base.should == "00000000000"
        deck.primary_borrower_income_overtime.should == "00000000000"
        deck.primary_borrower_income_commission.should == "00000000000"
        deck.primary_borrower_income_bonus.should == "00000000000"
        deck.primary_borrower_income_dividend.should == "00000000000"
        deck.primary_borrower_income_rental.should == "00000000000"
        deck.primary_borrower_income_other.should == "00000000000"
        deck.primary_borrower_total_income.should == "0000000000000"
      end
    end

    describe "secondary borrower demographic fields" do
      it "secondary_borrower_birth_date" do
        secondary_borrower.birth_date = Date.new(1985, 3, 21)
        deck.secondary_borrower_birth_date.should == "0850321"
      end

      it "secondary_borrower_us_citizen_flag for US citizen" do
        secondary_borrower.citizenship_type = "USCitizen"
        deck.secondary_borrower_us_citizen_flag.should == 'Y'
      end

      it "secondary_borrower_us_citizen_flag for non US citizen" do
        secondary_borrower.citizenship_type = "Nope"
        deck.secondary_borrower_us_citizen_flag.should == 'N'
      end

      it "secondary_borrower_years_of_school" do
        secondary_borrower.schooling_years = 15
        deck.secondary_borrower_years_of_school.should == '15'
      end

      it "secondary_borrower_employer_name" do
        secondary_borrower.employer.name = 'Acme'
        deck.secondary_borrower_employer_name.should == 'Acme' + ' '*21
      end

      it "secondary_borrower_position" do
        secondary_borrower.employer.position = 'Flunky'
        deck.secondary_borrower_position.should == 'Flunky' + ' '*19
      end

      it "secondary_borrower_years_at_position" do
        secondary_borrower.employer.years_at_position = 2
        deck.secondary_borrower_years_at_position.should == '02'
      end

      it "secondary_borrower_months_at_position" do
        secondary_borrower.employer.months_at_position = 3
        deck.secondary_borrower_months_at_position.should == '03'
      end

      it "secondary_borrower_years_in_profession" do
        secondary_borrower.employer.years_in_profession = 2
        deck.secondary_borrower_years_in_profession.should == '02'
      end

      it "secondary_borrower_self_employed true" do
        secondary_borrower.employer.self_employment_flag = true
        deck.secondary_borrower_self_employed.should == 'Y'
      end

      it "secondary_borrower_self_employed false" do
        secondary_borrower.employer.self_employment_flag = false
        deck.secondary_borrower_self_employed.should == 'N'
      end
    end

    describe "income fields" do
      before do
        translator.stub secondary_borrower_income_of_type: 0
      end

      it "secondary_borrower_income_base" do
        translator.stub(:secondary_borrower_income_of_type).with("Base").and_return(98765.43)
        deck.secondary_borrower_income_base.should == "00009876543"
      end

      it "secondary_borrower_income_overtime" do
        translator.stub(:secondary_borrower_income_of_type).with("Overtime").and_return(98765.43)
        deck.secondary_borrower_income_overtime.should == "00009876543"
      end

      it "secondary_borrower commission income" do
        translator.stub(:secondary_borrower_income_of_type).with("Commission").and_return(98765.43)
        deck.secondary_borrower_income_commission.should == "00009876543"
      end

      it "secondary_borrower bonus income" do
        translator.stub(:secondary_borrower_income_of_type).with("Bonus").and_return(98765.43)
        deck.secondary_borrower_income_bonus.should == "00009876543"
      end

      it "secondary_borrower dividend income" do
        translator.stub(:secondary_borrower_income_of_type).with("DividendsInterest").and_return(98765.43)
        deck.secondary_borrower_income_dividend.should == "00009876543"
      end

      it "secondary_borrower rental income" do
        translator.stub(:secondary_borrower_income_of_type).with("NetRentalIncome").and_return(98765.43)
        deck.secondary_borrower_income_rental.should == "00009876543"
      end

      it "secondary_borrower rental income" do
        translator.stub secondary_borrower_income_other: 98765.43
        deck.secondary_borrower_income_other.should == "00009876543"
      end

      it "secondary_borrower total income" do
        translator.stub secondary_borrower_total_monthly_income: 98765.43
        deck.secondary_borrower_total_income.should == "0000009876543"
      end

      it "income fields should not be shown for employee loans" do
        translator.stub is_employee_loan?: 1
        translator.stub(:secondary_borrower_income_of_type).with("Base").and_return(2.22)
        translator.stub(:secondary_borrower_income_of_type).with("Overtime").and_return(1.11)
        translator.stub(:secondary_borrower_income_of_type).with("Commission").and_return(3.33)
        translator.stub(:secondary_borrower_income_of_type).with("Bonus").and_return(4.44)
        translator.stub(:secondary_borrower_income_of_type).with("DividendsInterest").and_return(4.44)
        translator.stub(:secondary_borrower_income_of_type).with("NetRentalIncome").and_return(5.55)
        translator.stub(:secondary_borrower_income_other).and_return(6.66)
        translator.stub(:secondary_borrower_total_monthly_income).and_return(7.77)
        deck.secondary_borrower_income_base.should == "00000000000"
        deck.secondary_borrower_income_overtime.should == "00000000000"
        deck.secondary_borrower_income_commission.should == "00000000000"
        deck.secondary_borrower_income_bonus.should == "00000000000"
        deck.secondary_borrower_income_dividend.should == "00000000000"
        deck.secondary_borrower_income_rental.should == "00000000000"
        deck.secondary_borrower_income_other.should == "00000000000"
        deck.secondary_borrower_total_income.should == "0000000000000"
      end
    end

    it "total_liability_amount" do
      translator.stub total_liability_amount: 12345.67
      deck.total_liability_amount.should == "0000001234567"
    end

    it "primary borrower credit score" do
      primary_borrower.credit_score = 456
      deck.credit_score_1_label.should == "Primary borrower credit score".ljust(30)
      deck.credit_score_1_value.should == "456".ljust(15)
    end

    it "secondary borrower credit score" do
      secondary_borrower.credit_score = 456
      deck.credit_score_2_label.should == "Secondary borrower creditscore".ljust(30)
      deck.credit_score_2_value.should == "456".ljust(15)
    end

    describe "fico_score" do
      before do
        loan.stub(:rep_fico_score).and_return(800)
        primary_borrower.credit_score = 787
        secondary_borrower.credit_score = 887
      end
      it "should use the primary borrower's credit score" do
        deck.fico_score.should == "800"
      end

      # context "when the secondary borrower has no credit score" do
      #   before { secondary_borrower.credit_score = nil }
      #   it "should use the primary borrower's credit score" do
      #     deck.fico_score.should == "787"
      #   end
      # end
      # context "when the primary borrower has no credit score" do
      #   before { primary_borrower.credit_score = nil }
      #   it "should use the primary borrower's credit score" do
      #     deck.fico_score.should == "887"
      #   end
      # end
      # context "when they both have credit scores" do
      #   context "when the primary borrower's score is lower" do
      #     it "should use the lower score" do
      #       deck.fico_score.should == "787"
      #     end
      #   end
      #   context "when the secondary borrower's score is lower" do
      #     before do
      #       secondary_borrower.credit_score = 666
      #     end
      #     it "should use the lower score" do
      #       deck.fico_score.should == "666"
      #     end
      #   end
      # end
    end

    it "total_assets_value" do
      translator.stub total_assets_value: 999
      deck.total_assets_value.should == "0000000099900"
    end

    it "total_stock_value" do
      translator.stub total_stock_value: 999
      deck.total_stock_value.should == "0000000099900"
    end

    describe "flood_hazard_area" do
      it "should be Y when loan has 1" do
        loan.stub flood_hazard_area: 1
        deck.flood_hazard_area.should == 'Y'
      end

      it "should be Y when loan has '1'" do
        loan.stub flood_hazard_area: '1'
        deck.flood_hazard_area.should == 'Y'
      end

      it "should be N otherwise" do
        [0, 5, '0', '', nil].each do |val|
          loan.stub flood_hazard_area: val
          deck.flood_hazard_area.should == 'N'
        end
      end
    end

    describe "application_type" do
      it "should be 2 for FHA loans" do
        loan.stub mortgage_type: 'FHA'
        deck.application_type.should == '2'
      end

      it "should be 3 for VA loans" do
        loan.stub mortgage_type: 'VA'
        deck.application_type.should == '3'
      end

      it "should be 4 for FmHA loans" do
        loan.stub mortgage_type: 'FarmersHomeAdministration'
        deck.application_type.should == '4'
      end

      it "should be 1 otherwise" do
        ['XYZ', nil, ''].each do |val|
          loan.stub mortgage_type: val
          deck.application_type.should == '1'
        end
      end
    end

    describe "employee_loan_indicator" do
      it "should be 2 for true" do
        loan.stub employee_loan_indicator: true
        deck.employee_loan_indicator.should == '2'
      end

      it "should be blank otherwise" do
        loan.stub employee_loan_indicator: false
        deck.employee_loan_indicator.should == ' '
      end
    end

    it "branch_number should hardcode to zero" do
      translator.stub branch: 1212
      deck.branch_number.should == '00000'
    end

    it "first_payment_on" do
      loan.stub first_payment_on: Date.new(2013, 05, 31)
      deck.first_payment_on.should == '1130531'
    end

    it "product_code" do
      translator.stub loan_serv_product_code: 'abc'
      deck.product_code.should == 'abc  '
    end

    it 'loan_application_register_cra' do
      loan.stub product_code: 'C30FXD MCM'
      deck.loan_application_register_cra.should == 'Y'
    end

    describe "refinance codes" do
      context "when CTM holds the first lien on the mortgage loan" do
        before do
          loan.stub purpose_type: 'refinance'
          l = Master::Liability.new holder_name: 'CTM', liability_type: 'MortgageLoan',
            lien_position: 'FirstLien', reo_id: 'R1'
          loan.liabilities << l
          rp = Master::ReoProperty.new subject_indicator: 1, reo_id: 'R1'
          loan.stub_chain(:liabilities, :first_lien, :owned_by_ctm).and_return([l])
          loan.stub_chain(:reo_properties, :where).and_return([rp])
        end
        it { deck.internal_refinance_code.should == 'Y' }
        it { deck.external_refinance_code.should == 'N' }
      end

      context "when cole taylor mortgage holds the first lien on the mortgage loan" do
        before do
          loan.stub purpose_type: 'refinance'
          l = Master::Liability.new holder_name: 'cole taylor mortgage', liability_type: 'MortgageLoan',
            lien_position: 'FirstLien', reo_id: 'R1'
          rp = Master::ReoProperty.new subject_indicator: 1, reo_id: 'R1'
          loan.liabilities << l
          loan.stub_chain(:liabilities, :first_lien, :owned_by_ctm).and_return([l])
          loan.stub_chain(:reo_properties, :where).and_return([rp])
        end
        it { deck.internal_refinance_code.should == 'Y' }
        it { deck.external_refinance_code.should == 'N' }
      end

      context "when someone else holds the only mortgage loan" do
        before do
          loan.stub purpose_type: 'refinance'
          rp = Master::ReoProperty.new subject_indicator: 1, reo_id: 'R1' # even if it has an RP , but not CTM should be false.
          loan.stub_chain(:liabilities, :first_lien, :owned_by_ctm).and_return([])
          loan.stub_chain(:reo_properties, :where).and_return([rp])
        end
        it { deck.internal_refinance_code.should == 'N' }
        it { deck.external_refinance_code.should == 'Y' }
      end

      context "when its a purchase and not a refinance" do
        before do
          l = Master::Liability.new holder_name: 'cole taylor mortgage',
            liability_type: 'MortgageLoan', lien_position: 'FirstLien'
          loan.liabilities << l
          loan.stub(:purpose_type).and_return('purchase')
          l.stub(:loan).and_return(loan)
        end
        it { deck.internal_refinance_code.should == 'N' }
        it { deck.external_refinance_code.should == 'N' }
      end

      context "when someone else holds the first lien on the mortgage loan" do
        before do
          loan.stub(:purpose_type).and_return('refinance')
          loan.stub_chain(:liabilities, :first_lien, :owned_by_ctm).and_return([])
        end
        it { deck.internal_refinance_code.should == 'N' }
        it { deck.external_refinance_code.should == 'Y' }
      end

      context "when there are no other liens on the loan" do
        it "setup check" do
          loan.liabilities.should be_empty
        end
        it { deck.internal_refinance_code.should == 'N' }
        it { deck.external_refinance_code.should == 'N' }
      end
    end

    describe "borrower_paid_discount_points" do
      before do
        loan.stub property_usage_type: 'PrimaryResidence'
        loan.stub purpose_type: 'Purchase'
        loan.stub institution_id: '00098'
        loan.stub borrower_paid_discount_points: 1234.56
      end

      it "should have an amount for purchase of primary residence" do
        loan.stub property_usage_type: 'PrimaryResidence'
        deck.borrower_paid_discount_points.should == '0123456'
      end

      it "should have an amount for purchase of second home" do
        loan.stub property_usage_type: 'SecondHome'
        deck.borrower_paid_discount_points.should == '0123456'
      end

      ['ThirdHome', nil, ''].each do |val|
        it "should be 0 for property usage #{val.inspect}" do
          loan.stub property_usage_type: val
          deck.borrower_paid_discount_points.should == '0000000'
        end
      end

      it "should be zero when the institution is something else" do
        loan.stub institution_id: '01234'
        deck.borrower_paid_discount_points.should == '0000000'
      end

      it "should be zero when the loan is not for purchase" do
        loan.stub purpose_type: 'Refinance'
        deck.borrower_paid_discount_points.should == '0000000'
      end
    end

    describe "refinance_date" do
      before { loan.closing_on = Date.new(2013, 1, 2) }
      context "when the loan is a refinance" do
        before { loan.purpose_type = "Refinance" }
        it "should be the closing date" do
          deck.refinance_date.should == "1130102"
        end
      end
      context "when the loan is not a refinance" do
        before { loan.purpose_type = "Purchase" }
        it "should be blank" do
          deck.refinance_date.should == "0000000"
        end
      end
    end

    describe "refinance purpose" do
      before { loan.purpose_type = 'Refinance' }
      context "when refinance purpose is CashOutDebtConsolidation" do
        before { loan.gse_refinance_purpose_type = "CashOutDebtConsolidation" }
        it "refinance_purpose fields" do
          deck.refinance_purpose_cash.should == "C"
          deck.refinance_purpose_reason.should == "D"
        end
      end

      context "when refinance purpose is CashOutHomeImprovement" do
        before { loan.gse_refinance_purpose_type = "CashOutHomeImprovement" }
        it "refinance_purpose fields" do
          deck.refinance_purpose_cash.should == "C"
          deck.refinance_purpose_reason.should == "I"
        end
      end

      context "when refinance purpose is CashOutLimited" do
        before { loan.gse_refinance_purpose_type = "CashOutLimited" }
        it "refinance_purpose fields" do
          deck.refinance_purpose_cash.should == "N"
          deck.refinance_purpose_reason.should == "."
        end
      end

      context "when refinance purpose is ChangeInRateTerm" do
        before { loan.gse_refinance_purpose_type = "ChangeInRateTerm" }
        it "refinance_purpose fields" do
          deck.refinance_purpose_cash.should == "N"
          deck.refinance_purpose_reason.should == "."
        end
      end

      context "when the loan is not a refinance" do
        before { loan.purpose_type = "Purchase" }
        it "refinance_purpose fields should be blank" do
          deck.refinance_purpose_cash.should == " "
          deck.refinance_purpose_reason.should == " "
        end
      end
    end

    describe "app_received_on" do
      context "pre trid loans" do
        before { loan.stub trid_loan?: false }
        it "app_received_on" do
          loan.stub app_received_on: Date.new(2013, 5, 31)
          deck.app_received_on.should == '1130531'
        end
      end
      
      context "post trid loans" do
        before { loan.stub trid_loan?: true }
        it "should come from compliance alerts" do
          dt = Date.new 2015, 6, 23
          loan.compliance_alerts << Master::ComplianceAlert.new({application_date: dt - 1.days}, without_protection: true)
          loan.compliance_alerts << Master::ComplianceAlert.new({application_date: dt}, without_protection: true)
          deck.app_received_on.should == "1150623"
        end
      end
    end

    it "primary borrower name" do
      primary_borrower.first_name = 'John.,'
      primary_borrower.middle_name = 'Francis    ;, '
      primary_borrower.last_name = 'Noodlewhack, D.D.C.'
      primary_borrower.suffix = 'III'
      deck.primary_borrower_name.should == 'John Francis Noodlewhack DDC III   '
    end

    it "primary borrower name" do
      primary_borrower.first_name = "J'oh-n.,"
      primary_borrower.middle_name = '  '
      primary_borrower.last_name = 'Noodlewhack, D.D.C.'
      primary_borrower.suffix = 'JR'
      deck.primary_borrower_name.should == "J'oh-n Noodlewhack DDC JR          "
    end

    it "primary borrower name" do
      primary_borrower.first_name = 'John.,'
      primary_borrower.middle_name = nil
      primary_borrower.last_name = 'Noodlewhack, D.D.C.'
      deck.primary_borrower_name.should == 'John Noodlewhack DDC               '
    end

    it "primary brw ssn" do
      primary_borrower.ssn = 555667777
      deck.primary_ssn.should == '555667777'
    end

    it "primary brw home phone" do
      primary_borrower.home_phone_num = '3335551212'
      deck.primary_home_phone.should == '13335551212'
    end

    it "primary borrower work phone" do
      primary_borrower.employer.phone_num = '1112223333'
      deck.primary_work_phone.should == '11112223333'
    end

    it "primary borrower age" do
      primary_borrower.age_at_application = 25
      deck.primary_age_years.should == '025'
    end

    it "primary marital status" do
      translator.stub primary_marital_status: 'S'
      deck.primary_marital_status.should == 'S'
    end

    it "primary race" do
      translator.stub primary_race: 'X'
      deck.primary_race.should == 'X'
    end

    it "primary gender" do
      translator.stub primary_gender: 'X'
      deck.primary_gender.should == 'X'
    end

    it "primary ethnicity" do
      translator.stub primary_ethnicity: 'X'
      deck.primary_ethnicity.should == 'X'
    end

    it "secondary borrower name" do
      secondary_borrower.first_name = 'John.,'
      secondary_borrower.middle_name = 'Francis    ;, '
      secondary_borrower.last_name = 'Noodlewhack, D.D.C.'
      secondary_borrower.suffix = 'OMG'
      deck.secondary_borrower_name.should == 'John Francis Noodlewhack DDC OMG   '
    end

    it "secondary borrower name" do
      secondary_borrower.first_name = 'John.,'
      secondary_borrower.middle_name = '  '
      secondary_borrower.last_name = 'Noodlewhack, D.D.C.'
      deck.secondary_borrower_name.should == 'John Noodlewhack DDC               '
    end

    it "secondary borrower name" do
      secondary_borrower.first_name = 'John.,'
      secondary_borrower.middle_name = nil
      secondary_borrower.last_name = 'Noodlewhack, D.D.C.'
      deck.secondary_borrower_name.should == 'John Noodlewhack DDC               '
    end

    it "secondary brw ssn" do
      secondary_borrower.ssn = 555667777
      deck.secondary_ssn.should == '555667777'
    end

    it "secondary brw home phone" do
      secondary_borrower.home_phone_num = '3335551212'
      deck.secondary_home_phone.should == '13335551212'
    end

    it "secondary borrower work phone" do
      secondary_borrower.employer.phone_num = '1112223333'
      deck.secondary_work_phone.should == '11112223333'
    end

    it "secondary borrower age" do
      secondary_borrower.age_at_application = 25
      deck.secondary_age_years.should == '025'
    end

    it "secondary marital status" do
      translator.stub secondary_marital_status: 'S'
      deck.secondary_marital_status.should == 'S'
    end

    it "secondary race" do
      translator.stub secondary_race: 'X'
      deck.secondary_race.should == 'X'
    end

    it "secondary gender" do
      translator.stub secondary_gender: 'X'
      deck.secondary_gender.should == 'X'
    end

    it "secondary ethnicity" do
      translator.stub secondary_ethnicity: 'X'
      deck.secondary_ethnicity.should == 'X'
    end

    it "property address" do
      loan.property_address = "123 Grove. Street.."
      deck.property_address.should == "123 Grove Street" + " "*54
    end

    it "property_state" do
      loan.property_state = 'OH'
      deck.property_state.should == 'OH'
    end

    it "property_city" do
      loan.property_city = 'Ann Arbor'
      deck.property_city.should == 'Ann Arbor' + ' '*(35-9)
    end

    it "property_postal_code" do
      loan.property_postal_code = 'CBJ 9VD'
      deck.property_postal_code.should == 'CBJ 9VD  '
    end

    it "flood_map_panel_number should remove spaces" do
      loan.flood_determination_nfip_map_identifier = 'ab  c d'
      deck.flood_map_panel_number.should == 'abcd       '
    end

    it "flood_certification_identifier" do
      loan.flood_certification_identifier = 'abcdefg'
      deck.flood_certification_identifier.should == 'abcdefg'.ljust(20, ' ')
    end

    describe "mailing address fields" do
      before do
        loan.purpose_type = 'Purchase'

        loan.property_address = "999 N. Foo Ave"
        loan.property_state = 'MI'
        loan.property_city = 'Ypsilanti'
        loan.property_postal_code = '1234567'

        primary_borrower.residence.address = "123 S. Grove Street"
        primary_borrower.residence.state = "OH"
        primary_borrower.residence.city = 'Ann Arbor'
        primary_borrower.residence.postal_code = 'CBJ 9VD'
      end

      context "when the property is the primary residence" do
        before do
          loan.property_usage_type = 'PrimaryResidence'
        end

        it { deck.mailing_address.should == "999 N Foo Ave     ".upcase + " "*52 }
        it { deck.mailing_state.should == 'MI' }
        it { deck.mailing_city.should == 'Ypsilanti'.upcase + ' '*(35-9) }
        it { deck.mailing_postal_code.should == '1234567  ' }

        it "when the loan is not a purchase use the residence address instead" do
          loan.purpose_type = 'Refinance'

          deck.mailing_address.should == "999 N Foo Ave     ".upcase + " "*52
          deck.mailing_state.should == 'MI'
          deck.mailing_city.should == 'Ypsilanti'.upcase + ' '*(35-9)
          deck.mailing_postal_code.should == '1234567  '
        end

        it "when the loan.property_address is blank, don't populate address" do
          loan.purpose_type = 'Refinance'
          loan.property_address = ''

          deck.mailing_address.should == " "*70
          deck.mailing_state.should == " "*2
          deck.mailing_city.should == " "*35
          deck.mailing_postal_code.should == "00000" + " "*4
        end
      end

      context "when the property is not the primary residence" do
        before do
          loan.property_usage_type = 'SecondHome'
        end

        it { deck.mailing_address.should == "123 S Grove St".upcase + " "*56 }
        it { deck.mailing_state.should == 'OH' }
        it { deck.mailing_city.should == 'Ann Arbor'.upcase + ' '*(35-9) }
        it { deck.mailing_postal_code.should == 'CBJ 9VD  ' }
      end

      context "when the loan is not primary residence" do
        before do
          loan.property_usage_type = 'SecondHome'
        end

        it "returns the property address" do
          deck.mailing_address.should == "123 S Grove St".upcase + " "*56
          deck.mailing_state.should == 'OH'
          deck.mailing_city.should == 'Ann Arbor'.upcase + ' '*(35-9)
          deck.mailing_postal_code.should == 'CBJ 9VD  '
        end
      end

      context "When there is a mail_to address and is not the primary residence" do
        before do
          loan.property_usage_type = 'SecondHome'
          mail_to = Master::MailTo.new({loan: loan, borrower_id: 'BRW1', street_address: '123 Acme Boulevard',
            street_address_2: 'Suite 100', city: 'Howell', state: 'MI', postal_code: '48105'}, without_protection: true)
          primary_borrower.stub(:mail_to).and_return(mail_to)
        end
        its '.mailing_address' do
          deck.mailing_address.should == "123 Acme BLVD STE 100                                                 ".upcase
        end
        its '.mailing_state' do
          deck.mailing_state.should == "MI"
        end
        its '.mailing_city' do
          deck.mailing_city.should == "Howell                             ".upcase
        end
        its '.mailing_postal_code' do
          deck.mailing_postal_code.should == "48105    "
        end
      end

    end

    it "legal_description" do
      value = 'foobar' * 50
      loan.legal_descriptions << Master::LegalDescription.new({text: "nothing", description_type: 'Other'}, without_protection: true)
      loan.legal_descriptions << Master::LegalDescription.new({text: value, description_type: 'LongLegal'}, without_protection: true)
      deck.legal_description.should start_with(value)
    end

    it 'legal description format' do
      loan.legal_descriptions << Master::LegalDescription.new({text: "HI THIS \n IS A $ TEST 1923", description_type: 'LongLegal'}, without_protection: true)
      deck.legal_description.should_not include("\n")
    end

    describe "points_paid_other" do
      before do
        loan.property_usage_type = 'PrimaryResidence'
        loan.purpose_type = 'Refinance'
        loan.institution_id = '00098'
        loan.borrower_paid_discount_points = 1234.56
      end

      it "should be points when it's a primary residence refi from this institution" do
        deck.points_paid_other.should == '0123456'
      end

      it "should be points when it's a second home refi from this institution" do
        loan.property_usage_type = 'SecondHome'
        deck.points_paid_other.should == '0123456'
      end

      it "should be zero when not a pr or 2h" do
        loan.property_usage_type = 'slfjsfkj'
        deck.points_paid_other.should == '0000000'
      end

      it "should be zero when from another institution" do
        loan.institution_id = '00097'
        deck.points_paid_other.should == '0000000'
      end

      it "should be zero when it is not a refinance" do
        loan.purpose_type = 'Foo'
        deck.points_paid_other.should == '0000000'
      end
    end

    describe "statement_frequency" do
      it "should be blank for fixed rate loans" do
        loan.amortization_type = "Fixed"
        deck.statement_frequency.should == ' '
      end
      it "should be C for ARM loans" do
        loan.amortization_type = "AdjustableRate"
        deck.statement_frequency.should == 'C'
      end
    end

    describe "next_statement_date" do
      before { loan.first_payment_on = Date.new(2013, 4, 1) }
      it "should be blank for fixed rate loans" do
        loan.amortization_type = "Fixed"
        deck.next_statement_date.should == '0000000'
      end
      it "should be the 15th of the month prior to the next payment date for ARM loans" do
        loan.amortization_type = "AdjustableRate"
        deck.next_statement_date.should == '1130315'
      end
    end


    it "fiserv_phase_code should hardcode to 1 for originated loans" do
      deck.fiserv_phase_code.should == "001"
    end

    describe "primary_immigration_status" do
      context "when USCitizen" do
        before { primary_borrower.stub is_us_citizen?: true, is_permanent_resident?: true }
        it { deck.primary_immigration_status.should == '00' }
      end
      context "when PermanentResidentAlien" do
        before { primary_borrower.stub is_us_citizen?: false, is_permanent_resident?: true }
        it { deck.primary_immigration_status.should == '01' }
      end
      context "when NonPermanentResidentAlien" do
        before { primary_borrower.stub is_us_citizen?: false, is_permanent_resident?: false }
        it { deck.primary_immigration_status.should == '02' }
      end
    end

    describe "secondary_immigration_status" do
      context "when USCitizen" do
        before { secondary_borrower.stub is_us_citizen?: true, is_permanent_resident?: true }
        it { deck.secondary_immigration_status.should == '00' }
      end
      context "when PermanentResidentAlien" do
        before { secondary_borrower.stub is_us_citizen?: false, is_permanent_resident?: true }
        it { deck.secondary_immigration_status.should == '01' }
      end
      context "when NonPermanentResidentAlien" do
        before { secondary_borrower.stub is_us_citizen?: false, is_permanent_resident?: false }
        it { deck.secondary_immigration_status.should == '02' }
      end
    end

    describe "closing interest" do
      context "for post trid loans" do
        before do
          loan.stub trid_loan?: true

          loan.hud_lines << Master::HudLine.new({hud_type: "HUD", system_fee_name: "Interest",
              total_amount: 100.05}, without_protection: true)
          loan.hud_lines << Master::HudLine.new({hud_type: "HUD", system_fee_name: "Prepaid Interest",
              total_amount: 100.01}, without_protection: true)
          loan.hud_lines << Master::HudLine.new({hud_type: "HUD", system_fee_name: "Prepaid Interest",
              total_amount: 100.02}, without_protection: true)
          loan.hud_lines << Master::HudLine.new({hud_type: "GFE", system_fee_name: "Prepaid Interest",
              total_amount: 100.03}, without_protection: true)
          loan.hud_lines << Master::HudLine.new({hud_type: "HUD", system_fee_name: "dlsfkjsfsd",
              total_amount: 100.04}, without_protection: true)
        end

        it "should sum the hud lines with system fee Interest" do
          expect(deck.closing_interest).to eq '00000020003'
        end

        it "should still not do anything for mini-corr" do
          loan.channel = Channel.mini_corr.identifier
          expect(deck.closing_interest).to eq '00000000000'
        end

      end

      context "for pre trid loans" do
        before { loan.stub trid_loan?: false }
        context "when positive" do
          before do
            loan.hud_lines << Master::HudLine.new({line_num: 901, system_fee_name: 'Interest',
                                                   hud_type: 'GFE', total_amount: 100_000.56}, without_protection: true)
            loan.hud_lines << Master::HudLine.new({line_num: 901, system_fee_name: 'Interest',
                                                   hud_type: 'HUD', total_amount: 90_000.56}, without_protection: true)
          end
          it "behaves normally" do
            deck.closing_interest.should == '00009000056'
          end
        end

        context "when the loan is mini-corr" do
          before do
            loan.channel = Channel.mini_corr.identifier
            loan.hud_lines << Master::HudLine.new({line_num: 901, system_fee_name: 'Interest',
                                                   hud_type: 'HUD', total_amount: 90_000.56}, without_protection: true)
          end
          it "should be zero" do
            deck.closing_interest.should == '00000000000'
          end
        end

        context "when negative" do
          before do
            loan.hud_lines << Master::HudLine.new({line_num: 901, system_fee_name: 'Interest',
                                                   hud_type: 'HUD', total_amount: -1_000.56}, without_protection: true)
          end

          it "should put a positive amount for the actual field" do
            deck.closing_interest.should == '-00000100056'
          end
        end
      end
    end

    describe "closing escrow balance" do
      context "pre trid" do
        before { loan.stub trid_loan?: false }
        it "should add hud lines between 1002 and 1010" do
          (1001..1011).each do |num|
            loan.hud_lines << Master::HudLine.new({line_num: num, hud_type: 'HUD',
                                                   total_amount: 100.01}, without_protection: true)
          end
          loan.hud_lines << Master::HudLine.new({line_num: 1009, hud_type: 'GFE',
                                                 total_amount: 100.01}, without_protection: true)
          deck.closing_escrow_balance.should == '00000090009'
        end
      end

      context "post trid" do
        before { 
          loan.stub trid_loan?: true 
          loan.stub escrow_waiver_indicator: false
        }
        it "should add hud lines with the right fee category" do
          loan.hud_lines << Master::HudLine.new({hud_type: "HUD", fee_category: "InitialEscrowPaymentAtClosing", total_amount: 100.01, net_fee_indicator: true }, without_protection: true) #yes
          loan.hud_lines << Master::HudLine.new({hud_type: "HUD", fee_category: "InitialEscrowPaymentAtClosing", total_amount: 100.02, net_fee_indicator: true }, without_protection: true) #yes
          loan.hud_lines << Master::HudLine.new({hud_type: "GFE", fee_category: "InitialEscrowPaymentAtClosing", total_amount: 100.03, net_fee_indicator: true }, without_protection: true) #no - wrong hud type
          loan.hud_lines << Master::HudLine.new({hud_type: "HUD", fee_category: "sdlfkjsd", total_amount: 100.04, net_fee_indicator: true }, without_protection: true) #no - wrong fee category
          deck.closing_escrow_balance.should == '00000020003'
          deck.escrow_balance.should == '00000020003'
        end
      end

      context "Returns proper value when LOCK_LOAN_DATA.EscrowWaiverIndicator = 1 (true)" do
        it "returns 0 when no mortgage insurance" do
          loan.hud_lines << Master::HudLine.new({line_num: 1003, hud_type: 'HUD', monthly_amount: 0.0, 
                                                system_fee_name: 'Mortgage Insurance'}, without_protection: true)

          loan.stub :escrow_waiver_indicator => true
          expect(deck.closing_escrow_balance).to eq('00000000000')
          expect(deck.escrow_balance).to eq('00000000000')
        end

        it "returns mortgage insurance amount when there is mortgage insurance" do
          loan.hud_lines << Master::HudLine.new({line_num: 1003, hud_type: 'HUD', total_amount: 100.01, 
                                                system_fee_name: 'Mortgage Insurance'}, without_protection: true)

          loan.stub :escrow_waiver_indicator => true
          expect(deck.closing_escrow_balance).to eq('00000010001')
          expect(deck.escrow_balance).to eq('00000010001')
        end
      end

    end

    # this is the same as closing escrow balance, for loans we originate.  When we get to
    # TSS or minicorr, will have to revisit this.
    it "escrow balance" do
      (1001..1011).each do |num|
        loan.hud_lines << Master::HudLine.new({line_num: num, hud_type: 'HUD',
                                              total_amount: 100.01}, without_protection: true)
      end
      loan.hud_lines << Master::HudLine.new({line_num: 1009, hud_type: 'GFE',
                                            total_amount: 100.01}, without_protection: true)
      deck.escrow_balance.should == '00000090009'
    end

    describe "closing_escrow_payment" do
      context "post TRID loans" do
        before { loan.stub :trid_loan? => true }

        it "should add monthly amount for matching hud lines" do
          matching_values = { hud_type: 'HUD', fee_category: 'InitialEscrowPaymentAtClosing', 
                              system_fee_name: 'foo', monthly_amount: 0, net_fee_indicator: true }
          loan.hud_lines << Master::HudLine.new(matching_values.merge(monthly_amount: 1.01), without_protection: true)
          loan.hud_lines << Master::HudLine.new(matching_values.merge(monthly_amount: 2.02), without_protection: true)
          loan.hud_lines << Master::HudLine.new(matching_values.merge(system_fee_name: 'Aggregate Adjustment', monthly_amount: 5.05), without_protection: true)
          # should not include GFE lines
          loan.hud_lines << Master::HudLine.new(matching_values.merge(hud_type: 'GFE', monthly_amount: 3.03), without_protection: true)
          # should not include other fee categories
          loan.hud_lines << Master::HudLine.new(matching_values.merge(fee_category: 'sometehing else', monthly_amount: 4.04), without_protection: true)

          deck.closing_escrow_payment.should == '000000808'
        end
      end

      context "pre TRID loans" do
        before { 
          loan.stub :trid_loan? => false 
          loan.stub :escrow_waiver_indicator => false
        }

        it "closing_escrow_payment should be the sum of the monthly amount of all escrow payments" do
          (1001..1010).each do |num|
            loan.hud_lines << Master::HudLine.new({line_num: num, hud_type: 'HUD',
                                                   monthly_amount: 1.02}, without_protection: true)
          end
          loan.hud_lines << Master::HudLine.new({line_num: 1007, hud_type: 'GFE',
                                                 monthly_amount: 100.01}, without_protection: true)
          deck.closing_escrow_payment.should == '000000816'
        end

        it "closing_escrow_payment should handle negative value properly" do
          loan.hud_lines << Master::HudLine.new({line_num: 1002, hud_type: 'HUD',
                                                 monthly_amount: -1.02}, without_protection: true)

          deck.closing_escrow_payment_sign.should == '-'
          deck.closing_escrow_payment.should == '000000102'
        end
      end

      context "Returns proper value when LOCK_LOAN_DATA.EscrowWaiverIndicator = 1 (true)" do
        it "returns 0 when no mortgage insurance" do
          loan.hud_lines << Master::HudLine.new({line_num: 1003, hud_type: 'HUD', monthly_amount: 0.0, 
                                                system_fee_name: 'Mortgage Insurance'}, without_protection: true)

          loan.stub :escrow_waiver_indicator => true
          expect(deck.closing_escrow_payment).to eq('000000000')
        end

        it "returns mortgage insurance amount when there is mortgage insurance" do
          loan.hud_lines << Master::HudLine.new({line_num: 1003, hud_type: 'HUD', monthly_amount: 100.01, 
                                                system_fee_name: 'Mortgage Insurance'}, without_protection: true)

          loan.stub :escrow_waiver_indicator => true
          expect(deck.closing_escrow_payment).to eq('000010001')
        end
      end
    end

    describe "billing_method" do
      context "for ARM loans" do
        before { loan.amortization_type = "AdjustableRate" }
        it { deck.billing_method.should == '1' }
      end
      context "for other loans" do
        before { loan.amortization_type = "Fixed" }
        it { deck.billing_method.should == 'C' }
      end
    end

    it "tax servicer id should hardcode to 1" do
      deck.tax_servicer_id.should == '01'
    end

    it "partial_payment_code should hardcode to 2" do
      deck.partial_payment_code.should == '2'
    end

    it "servicing purchased flag should hardcode to N for originated loans" do
      deck.servicing_purchased_flag.should == 'N'
    end

    it "coupon flag should hardcode to 0" do
      deck.coupon_flag.should == '0'
    end

    describe "new_construction_flag" do
      it "should be Y for 1" do
        loan.new_construction = 1
        deck.new_construction_flag.should == 'Y'
      end

      it "should be N for 0" do
        loan.new_construction = 0
        deck.new_construction_flag.should == 'N'
      end
    end

    describe "investor_block_code" do
      [1, 4, 6, 8].each do |n|
        context "when the loan number starts with #{n}" do
          before { loan.loan_num = "#{n}0000001".to_i }
          it { deck.investor_code.should == '11001' }
          it { deck.investor_block_code.should == "0000#{n}" }
        end

        context "when the loan channel is Private" do
          before do
            loan.channel = 'P0-Private Banking Standard'
            loan.loan_num = "#{n}0000001".to_i 
          end
          it { deck.investor_code.should == '14001' }
          it { deck.investor_block_code.should == "00001" }
        end
      end
    end

    it 'refinance_indicator' do
      loan.stub(:product_code).and_return('C20FXD RP')
      deck.refinance_indicator.should == 'PLS'
    end

    describe "occupancy_code" do
      it "should be 2 when property_usage_type is investor" do
        loan.property_usage_type = 'Investor'
        deck.occupancy_code.should == '2'
      end

      ['PrimaryResidence', 'SecondHome'].each do |value|
        it "should be 1 when property_usage_type is #{value}" do
          loan.property_usage_type = value
          deck.occupancy_code.should == '1'
        end
      end

      it "should be blank otherwise" do
        [nil, ''].each do |value|
          loan.property_usage_type = value
          deck.occupancy_code.should == ' '
        end
      end
    end

    it "original_ltv" do
      loan.original_ltv = 82.34
      deck.original_ltv.should == '08234'
    end

    it "mers_min_number" do
      loan.min_number = '1234567890'
      deck.mers_min_number.should == '1234567890        '
    end

    it "mers_originating_org_id" do
      loan.min_number = '9234567890'
      deck.mers_originating_org_id.should == '9234567'
    end

    it "mers_registration_date" do
      loan.mers_registration_date = Date.new(2013, 1, 1)
      deck.mers_registration_date.should == "1130101"
    end

    describe "insurance_or_guaranty_date" do
      before { loan.insured_on = Date.new(2014, 3, 21) }

      [ "Conventional", "FHA" ].each do |mortgage_type|
        context "when mortgage type is #{mortgage_type}" do
          before { loan.mortgage_type = mortgage_type }
          it "should be the insured on date" do
            deck.insurance_or_guaranty_date.should == "1140321"
          end
        end
      end

      context "when mortgage type is something else" do
        before { loan.mortgage_type = 'asldfjsdf' }
        it "should be blank" do
          deck.insurance_or_guaranty_date.should == '0000000'
        end
      end
    end

    describe "second_mortgage_code" do
      context "when there is a second mortgage" do
        before { translator.stub :has_subordinate_financing? => true }
        it { deck.second_mortgage_code.should == '1' }
      end
      context "when there is not a second mortgage" do
        before { translator.stub :has_subordinate_financing? => false }
        it { deck.second_mortgage_code.should == '0' }
      end
    end

    describe "escrow interest fields" do
      context "when escrow pays interest" do
        before { translator.stub :escrow_pays_interest? => true }
        it "should hardcode these fields" do
          deck.escrow_interest_code.should == '001'
          deck.escrow_interest_sub_code.should == '001'
          deck.escrow_precalculated_interest.should == '0000000'
        end
      end
      context "when escrow does not pay interest" do
        before { translator.stub :escrow_pays_interest? => false }
        it "should not set interest code fields" do
          Fiserv::CardDeck.any_instance.should_not_receive(:"escrow_interest_code=")
          Fiserv::CardDeck.any_instance.should_not_receive(:"escrow_interest_sub_code=")
          deck
        end

        it "should hardcode the precalc interest field" do
          deck.escrow_precalculated_interest.should == '-9999999'
        end
      end
    end

    describe "mers registration flags" do
      context "flags should be hardcoded" do
        it { deck.mers_registration_flag.should == 'Y' }
        it { deck.mers_flag_indicator.should == 'R' }
      end
    end

    it "grace_period - reimbursement" do
      loan.channel = 'R0 - Reimbursement'
      deck.grace_period.should == '015'
    end

    it "grace_period" do
      loan.grace_period = 5
      deck.grace_period.should == '005'
    end

    it "annual_percentage_rate" do
      loan.apr_rate = 2.34
      deck.annual_percentage_rate.should == "00234"
    end

    it "initial_statement_indicator should be N" do
      deck.initial_statement_indicator.should == "N"
    end

    describe "prepay_penalty_flag" do
      it "should write 0 for false" do
        loan.prepayment_penalty_indicator = false
        deck.prepay_penalty_flag.should == '0'
      end

      it "should write 1 for true" do
        loan.prepayment_penalty_indicator = true
        deck.prepay_penalty_flag.should == '1'
      end
    end

    describe "hpml_indicator" do
      it "should set the indicator to 'Y' if the channel is R0-Reimbursement Standard and there is a HPML custom field" do
        loan.stub(:channel).and_return("R0-Reimbursement Standard")
        loan.stub_chain(:custom_fields, :where).and_return([OpenStruct.new({attribute_value: 'Yes'})])
        deck.hpml_indicator.should == 'Y'
      end

      it "should set the to 'N' indicator if the channel is R0-Reimbursement Standard and there is not a HPML custom field" do
        loan.stub(:channel).and_return("R0-Reimbursement Standard")
        loan.stub_chain(:custom_fields, :where).and_return([])
        deck.hpml_indicator.should == 'N'
      end

      it "should not set hpml_indicator when the latest result is false" do
        loan.stub(:is_primary_residence?).and_return(true)
        HpmlResult.stub(:for) { false }

        deck.hpml_indicator.should == 'N'
      end

      it "should be Y when the latest result is true" do
        loan.stub(:is_primary_residence?).and_return(true)
        HpmlResult.stub(:for) { true }

        deck.hpml_indicator.should == 'Y'
      end
    end

    describe "lpmi fields" do
      it "should set lpmi values according to specs" do
        loan.original_balance = 100000 
        loan.mi_lender_paid_rate_percent = 25.252525
        loan.lender_paid_mi = true
        loan.original_ltv = 98
        loan.loan_amortization_term = 120

        deck.lpmi_premium.should    == '2525253'
        deck.lpmi_tax_amount.should == '0000000'
        deck.lpmi_balance.should    == '0000000'   
        deck.lpmi_type_flag.should  == 'O'
        deck.lpmi_rate_percent.should == '035'
      end

      it "should not set lpmi unless lender_paid_mi is true" do
        loan.original_balance = 100000 
        loan.mi_lender_paid_rate_percent = 25.252525
        loan.lender_paid_mi = false
        
        Fiserv::CardDeck.any_instance.should_not_receive(:"lpmi_premium=") 
        deck
      end
    end

    describe "late charge codes" do
      it "when state is MA" do
        loan.property_state = 'MA'
        loan.mortgage_type = 'FHA'
        loan.late_charge_rate = 1.234

        expect(deck.late_charge_assess_code).to eql('0')
        expect(deck.late_charge_code).to eql('1')
        deck.late_charge_rate.should == '03000'
      end

      it "when state is NY and mortgage_type is Other" do
        loan.property_state = 'NY'
        loan.mortgage_type = 'Other'
        loan.late_charge_rate = 1.234

        expect(deck.late_charge_assess_code).to eql('0')
        expect(deck.late_charge_code).to eql('1')
        deck.late_charge_rate.should == '02000'
      end

      it "when state is CA and mortgage_type is VA" do
        loan.property_state = 'CA'
        loan.mortgage_type = 'VA'
        loan.late_charge_rate = 1.234

        expect(deck.late_charge_assess_code).to eql('1')
        expect(deck.late_charge_code).to eql('2')
        deck.late_charge_rate.should == '01234'
      end

      it "when state is CA and mortgage_type is FHA" do
        loan.property_state = 'CA'
        loan.mortgage_type = 'FHA'
        loan.late_charge_rate = 1.235

        expect(deck.late_charge_assess_code).to eql('1')
        expect(deck.late_charge_code).to eql('1')
        deck.late_charge_rate.should == '01235'
      end

      it "when state is NC and mortgage_type is FHA" do
        loan.property_state = 'NC'
        loan.mortgage_type = 'FHA'
        loan.late_charge_rate = 2.345

        expect(deck.late_charge_assess_code).to eql('1')
        expect(deck.late_charge_code).to eql('2')
        deck.late_charge_rate.should == '02345'
      end

      it "when state is NC and mortgage_type is Other and loan.original_balance < 300000" do
        loan.property_state = 'NC'
        loan.mortgage_type = 'Other'
        loan.original_balance = 299999
        loan.late_charge_rate = 1.345

        expect(deck.late_charge_assess_code).to eql('1')
        expect(deck.late_charge_code).to eql('1')
        deck.late_charge_rate.should == '04000'
      end

      it "when state is NC and mortgage_type is Other and loan.original_balance >= 300000" do
        loan.property_state = 'NC'
        loan.mortgage_type = 'Other'
        loan.original_balance = 300000
        loan.late_charge_rate = 1.345

        expect(deck.late_charge_assess_code).to eql('1')
        expect(deck.late_charge_code).to eql('1')
        deck.late_charge_rate.should == '01345'
      end

      it "when state is NC and mortgage_type is Other and loan.original_balance >= 300000 and it's a trid loan" do
        loan.property_state = 'NC'
        loan.mortgage_type = 'Other'
        loan.original_balance = 300000
        loan.late_charge_rate = 1.345
        loan.late_charge_percentage = 3.345
        loan.stub trid_loan?: true

        expect(deck.late_charge_assess_code).to eql('1')
        expect(deck.late_charge_code).to eql('1')
        deck.late_charge_rate.should == '03345'
      end


      it "when state is DC and mortgage_type is FHA" do
        loan.property_state = 'DC'
        loan.mortgage_type = 'FHA'
        loan.late_charge_rate = 1.345

        expect(deck.late_charge_assess_code).to eql('0')
        expect(deck.late_charge_code).to eql('1')
        deck.late_charge_rate.should == '01345'
      end

      it "when state is MI and mortgage_type is FHA" do
        loan.property_state = 'MI'
        loan.mortgage_type = 'FHA'
        loan.late_charge_rate = 2.345

        expect(deck.late_charge_assess_code).to eql('0')
        expect(deck.late_charge_code).to eql('2')
        deck.late_charge_rate.should == '02345'
      end

      it "when state is KY and mortgage_type is Other" do
        loan.property_state = 'KY'
        loan.mortgage_type = 'Other'
        loan.late_charge_percentage = 3.345
        loan.stub trid_loan?: true

        expect(deck.late_charge_assess_code).to eql('0')
        expect(deck.late_charge_code).to eql('1')
        deck.late_charge_rate.should == '03345'
      end
    end

    describe "mi_termination_date" do
      before do
        loan.mortgage_type = "Conventional"
        loan.stub has_mi?: true
        loan.mi_scheduled_termination_date = Date.new(2003, 4, 5)
        loan.original_ltv = 91
      end

      it "should not come from scheduled termination date" do
        deck.mi_termination_date.should_not == "1030405"
      end

      it "should not set a value when the loan is not conventional" do
        loan.mortgage_type = "Something Else"
        deck.mi_termination_date.should == '0000000'
      end

      it "should not set a value when the loan has no MI" do
        loan.stub has_mi?: false
        deck.mi_termination_date.should == '0000000'
      end

      it "should not set it when there is no first payment date" do
        loan.amortization_term = 15*12
        loan.final_note_rate = 4.5
        loan.principal_and_interest_payment = 764.99
        loan.purchase_price = 100_000
        loan.property_appraised_amt = 120_000
        loan.first_payment_on = nil

        deck.mi_termination_date.should == '0000000'
      end

      it "15 year at 4.5% for 100k with 764.99 monthly payment" do
        loan.amortization_term = 15*12
        loan.final_note_rate = 4.5
        loan.first_payment_on = Date.new(2014, 2, 1)
        loan.principal_and_interest_payment = 764.99
        loan.purchase_price = 100_000
        loan.property_appraised_amt = 120_000

        expect(deck.mi_termination_date).to eql("1180501")
      end

      it "30 year at 4% for 120k with 477.42 monthly payment" do
        loan.amortization_term = 30*12
        loan.final_note_rate = 4
        loan.first_payment_on = Date.new(2014, 6, 1)
        loan.principal_and_interest_payment = 477.42
        loan.purchase_price = 120_000
        loan.property_appraised_amt = 130_000

        expect(deck.mi_termination_date).to eql("1171101")
      end

      it "30 year at 4% appraised for 120k sold for 160k with 716.12 monthly payment" do
        loan.amortization_term = 30*12
        loan.final_note_rate = 4
        loan.first_payment_on = Date.new(2014, 6, 1)
        loan.principal_and_interest_payment = 716.12
        loan.purchase_price = 160_000
        loan.property_appraised_amt = 120_000

        expect(deck.mi_termination_date).to eql("1300201")
      end

      it "should not set it when ltv is <= 78" do
        loan.original_ltv = 75

        deck.mi_termination_date.should == '0000000'
      end
    end

    describe 'when mortgage_type is FarmersHomeAdministration' do
      it "set up rhs" do
        loan.mortgage_type          = 'FarmersHomeAdministration'
        loan.property_state         = 'MI'
        loan.county_code            = 23
        loan.agency_case_identifier = '264-0682118-703'

        deck.rhs.should == "260232640682118703"
      end
    end

    describe "flood_certification_company" do

      it "When it contains First American use FAFDS" do
        loan.flood_certification_company_name = "foo First American bar"
        deck.flood_certification_company.should == "FAFDS"
      end

      it "should not set a value for other values of flood company name" do
        Fiserv::CardDeck.any_instance.should_not_receive(:"flood_certification_company=")
        loan.flood_certification_company_name = "Something Else"
        deck.flood_certification_company.should == "     "
      end
    end

    it 'flood_community_number_gm_29' do
      loan.stub flood_determination_nfip_community_identifier: "12312"
      deck.flood_community_number_gm_29.should == '12312 '
    end

    describe "flood_certification_company" do
      it 'flood_zone_gm_35' do
        loan.stub flood_determination_nfip_flood_zone_identifier: "NONE"
        deck.flood_zone_gm_35.should == 'NONE   '
      end

      it 'flood_zone_gm_35' do
        loan.stub flood_determination_nfip_flood_zone_identifier: "*ab"
        deck.flood_zone_gm_35.should == '*ab    '
      end
    end

    describe 'flood_determination_nfip_flood_zone_identifier' do
      it 'flood_loma_lomr_received' do
        loan.stub flood_determination_nfip_flood_zone_identifier: "NONE"
        deck.flood_loma_lomr_received.should == ' '
      end

      it 'flood_loma_lomr_received' do
        loan.stub flood_determination_nfip_flood_zone_identifier: "*ab"
        deck.flood_loma_lomr_received.should == 'N'
      end
    end

    describe "tax_service_type_required" do
      context "post trid loans" do
        before { loan.stub trid_loan?: true }

        it "should be B when there are no matching hud lines" do
          loan.hud_lines << build_hudline(hud_type: "GFE", system_fee_name: "City Taxes")
          loan.hud_lines << build_hudline(hud_type: "HUD", system_fee_name: "sdljfk")

          deck.tax_service_type_required.should == 'B'
        end

        [ "City Taxes", "County Taxes", "Annual Assessments", "Village Taxes", "School Taxes", 
          "Property Taxes", "Other Taxes",
        ].each do |fee_name|
          it "should be C if a hud line matches #{fee_name}" do
            loan.hud_lines << build_hudline(hud_type: "HUD", system_fee_name: fee_name)
            expect(deck.tax_service_type_required).to eq 'C'
          end
        end
      end


      context "pre trid loans" do
        before { loan.stub trid_loan?: false }
        context "when hud_line in 1004..1006" do
          [1004, 1005, 1006].each do |line_num|
            it { 
              loan.hud_lines << build_hudline(line_num: line_num, system_fee_name: 'Interest',
                                              hud_type: 'HUD', total_amount: 90_000.56, monthly_amount: 6.56)
              deck.tax_service_type_required.should == 'C' 
            }
          end
        end
        [1008, 1009].each do |line_num|
          %w(town village school sewer sanitation rail tax parcel).each do |fee|
            context "when hud_line in 1008 or 1009 and user defined fee is  #{fee} (tax related)" do
              it { 
                loan.hud_lines << build_hudline(line_num: line_num, system_fee_name: 'Interest',
                                                hud_type: 'HUD', total_amount: 90_000.56, monthly_amount: 6.56, user_defined_fee_name: "blah #{fee} blah")
                deck.tax_service_type_required.should == 'C' 
              }
            end
          end
        end
        context "when user defined fee is not one of tax types" do
          before { 
            loan.hud_lines << build_hudline(line_num: 1008, system_fee_name: 'Interest',
                                            hud_type: 'HUD', total_amount: 90_000.56, monthly_amount: 6.56, user_defined_fee_name: "blah insurance blah")
          }
          it { deck.tax_service_type_required.should == 'B' }
        end
        context "when hud line not in 1004..6" do
          before { 
            loan.hud_lines << build_hudline(line_num: 1002, system_fee_name: 'Interest',
                                            hud_type: 'HUD', total_amount: 90_000.56, monthly_amount: 6.56, user_defined_fee_name: "blah insurance blah")
          }
          it { deck.tax_service_type_required.should == 'B' }
        end
        context "when monthly_amount is 0" do
          [1004, 1005, 1006].each do |line_num|
            it { 
              loan.hud_lines << Master::HudLine.new(line_num: line_num, system_fee_name: 'Interest',
                                                    hud_type: 'HUD', total_amount: 90_000.56)
              deck.tax_service_type_required.should == 'B' 
            }
          end
          [1008, 1009].each do |line_num|
            %w(town village school sewer sanitation rail tax parcel).each do |fee|
              context "when hud_line in 1008 or 1009 and user defined fee is  #{fee} (tax related)" do
                it { 
                  loan.hud_lines << Master::HudLine.new(line_num: line_num, system_fee_name: 'Interest',
                                                        hud_type: 'HUD', total_amount: 90_000.56, monthly_amount: 0, user_defined_fee_name: "blah #{fee} blah")
                  deck.tax_service_type_required.should == 'B' 
                }
              end
            end
          end
        end
      end
    end

    it "should pass through the escrow disbursements" do
      translator.stub escrow_disbursement_containers: 'foo'
      Fiserv::CardDeck.any_instance.should_receive(:write_escrow_disbursements).with('foo').and_return('lsdjf')
      deck
    end

    describe "special feature codes" do
      before do
        translator.stub special_feature_code1: '123'
        translator.stub special_feature_code2: '223'
        translator.stub special_feature_code3: '323'
        translator.stub special_feature_code4: '423'
        translator.stub special_feature_code5: '523'
        translator.stub special_feature_code6: '623'
      end
      context "when it is a fnma loan" do
        before { 
          translator.stub :fhlmc_loan? => false
          translator.stub :fnma_loan? => true 
        }
        it "should write fnma special feature codes" do
          deck.fnma_special_feature_code1.should == '123'
          deck.fnma_special_feature_code2.should == '223'
          deck.fnma_special_feature_code3.should == '323'
          deck.fnma_special_feature_code4.should == '423'
          deck.fnma_special_feature_code5.should == '523'
          deck.fnma_special_feature_code6.should == '623'
        end
      end
      context "when it is a fhlmc loan" do
        before { 
          translator.stub(:fhlmc_loan?) { true } 
          translator.stub(:fnma_loan?) { false } 
        }
        it "should write fhlmc special feature codes" do
          deck.fhlmc_special_feature_code1.should == '123'
          deck.fhlmc_special_feature_code2.should == '223'
          deck.fhlmc_special_feature_code3.should == '323'
          deck.fhlmc_special_feature_code4.should == '423'
          deck.fhlmc_special_feature_code5.should == '523'
          deck.fhlmc_special_feature_code6.should == '623'
        end
      end

    end

    describe '#should_write_fnma?' do
      subject{ builder }
      context 'when loan is a fnma loan' do
        before do
          translator.should_receive(:fnma_loan?) { true }
          translator.stub(:fhlmc_loan?) { false }
        end

        its(:should_write_fnma?) { should be true }
      end

      context 'when loan is a freddie mac loan' do
        before do
          translator.stub(:fnma_loan?) { false }
          translator.stub(:fhlmc_loan?) { true }
        end

        its(:should_write_fnma?) { should be true }
      end

      context 'when loan is neither fannie mae or freddie mac' do
        before do
          translator.stub(:fnma_loan?) { false }
          translator.stub(:fhlmc_loan?) { false }
        end

        its(:should_write_fnma?) { should be false }
      end
    end

    describe 'mi_percentage_covered' do
      before { loan.mi_coverage_percent = 12.3 }

      context "for Conventional loans" do
        before { loan.mortgage_type = 'Conventional' }
        it "should be the coverage percent" do
          deck.mi_percentage_covered.should == '012'
        end

        it "should be 0 when the coverage percent is missing" do
          loan.mi_coverage_percent = nil
          deck.mi_percentage_covered.should == '000'
        end
      end

      context "for otehr loan types" do
        before { loan.mortgage_type = 'sdljf' }
        it "should be 0" do
          deck.mi_percentage_covered.should == '000'
        end
      end
    end

    describe "fnma block details" do
      before do
        builder.stub should_write_fnma?: true
      end

      it 'number_of_borrowers' do
        deck.number_of_borrowers.should == '03'
      end

      it "first_time_buyer_flag true" do
        loan.first_time_homebuyer_indicator = true
        deck.first_time_buyer_flag.should == 'Y'
      end

      it "first_time_buyer_flag false" do
        loan.first_time_homebuyer_indicator = false
        deck.first_time_buyer_flag.should == 'N'
      end

      it "monthly_housing_expense" do
        loan.proposed_housing_expenses <<
          Master::ProposedHousingExpense.new(payment_amount: 123.76) <<
          Master::ProposedHousingExpense.new(payment_amount: 456.11)
        deck.monthly_housing_expense.should == '00580'
      end

      it "total_monthly_liability" do
        loan.liabilities <<
          Master::Liability.new(monthly_payment_amount: 100) <<
          Master::Liability.new(monthly_payment_amount: 200)
        deck.total_monthly_liability.should == '00300'
      end

      describe "closing_cost_source1" do
        it "should be 09 when there are seller paid closing costs" do
          loan.seller_paid_closing_costs_amount = 123
          deck.closing_cost_source1.should == '09'
        end

        it "should be 00 when there are no seller paid closing costs" do
          loan.seller_paid_closing_costs_amount = 0
          deck.closing_cost_source1.should == '00'
        end
      end

      describe "closing_cost_source2" do
        it "should be 10 when there are estimated closing costs" do
          loan.estimated_closing_costs_amount = 123
          deck.closing_cost_source2.should == '10'
        end
        it "should be 00 when there are zero estimated closing costs" do
          loan.estimated_closing_costs_amount = 0
          deck.closing_cost_source2.should == '00'
        end
      end

      it "seller_paid_closing_costs_amount" do
        loan.seller_paid_closing_costs_amount = 123
        deck.seller_paid_closing_costs_amount.should == '000000012300'
      end

      it "estimated_closing_costs_amount" do
        loan.estimated_closing_costs_amount = 123
        deck.estimated_closing_costs_amount.should == '000000012300'
      end

      it "fnma_product_code" do
        translator.stub loan_serv_product_code: 'ABC'
        deck.fnma_product_code.should == 'ABC  '
      end



      describe "down payments" do
        before do
          loan.down_payments <<
            Master::DownPayment.new(down_payment_type: 'BBB', amount: 2500) <<
            Master::DownPayment.new(down_payment_type: 'AAA', amount: 1100) <<
            Master::DownPayment.new(down_payment_type: 'XXX', amount: 999) <<
            Master::DownPayment.new(down_payment_type: 'YYY', amount: 888)
          foo = Translation::DownPaymentSource.new('foo')
          Translation::DownPaymentSource.stub(:new).and_return(foo)
        end

        def stub_translation_for(a, b)
          xl = Translation::DownPaymentSource.new(a)
          xl.stub translate: b
          Translation::DownPaymentSource.stub(:new).with(a).and_return(xl)
        end

        it "down_payment_amount1" do
          deck.down_payment_amount1.should == '000000250000'
        end

        it "down_payment_amount2" do
          deck.down_payment_amount2.should == '000000110000'
        end

        it "down_payment_amount3" do
          deck.down_payment_amount3.should == '000000099900'
        end

        it "down_payment_amount4" do
          deck.down_payment_amount4.should == '000000088800'
        end

        it "down_payment_source1" do
          stub_translation_for 'BBB', '88'
          deck.down_payment_source1.should == '88'
        end

        it "down_payment_source2" do
          stub_translation_for 'AAA', '99'
          deck.down_payment_source2.should == '99'
        end

        it "down_payment_source3" do
          stub_translation_for 'XXX', '11'
          deck.down_payment_source3.should == '11'
        end

        it "down_payment_source4" do
          stub_translation_for 'YYY', '22'
          deck.down_payment_source4.should == '22'
        end
      end
    end


    it "should write 12 for tax service order flag" do
      deck.tax_service_order_flag.should == '12'
    end

    it "metro_stat_area" do
      loan.stub msa_identifier: '12'
      deck.metro_stat_area.should == "00012"
    end

    describe "foreign_address_flag" do
      context "when the country is usa" do
        before { 
          primary_borrower.residence.address = "123 Grove Street"
          primary_borrower.residence.state = "OH"
          primary_borrower.residence.city = 'Ann Arbor'
          primary_borrower.residence.postal_code = '12345' 
          primary_borrower.residence.country = 'United States'
        }
        it { deck.foreign_address_flag.should == 'N' }
        it { deck.distribution_mail_code.should == '0' }
      end
      context "when the country is nil" do
        before { 
          primary_borrower.residence.address = "123 Grove Street"
          primary_borrower.residence.state = "OH"
          primary_borrower.residence.city = 'Ann Arbor'
          primary_borrower.residence.postal_code = '     ' 
          primary_borrower.residence.country = nil
        }
        it { deck.foreign_address_flag.should == 'N' }
        it { deck.distribution_mail_code.should == '0' }
      end
      context "when the country is not usa" do
        before { 
          primary_borrower.residence.address = "123 Grove Street"
          primary_borrower.residence.state = "OH"
          primary_borrower.residence.city = 'Ann Arbor'
          primary_borrower.residence.postal_code = 'CB1 9GJ'
          primary_borrower.residence.country = 'United Arab Emirates'
          primary_borrower.home_phone_num = '3335551212'
          primary_borrower.employer.phone_num = '1112223333'

          mail_to = Master::MailTo.new({country: 'Australia', postal_code: 'A3B X4F'}, without_protection: true)
          primary_borrower.stub(:mail_to).and_return(mail_to)
        }

        it { deck.foreign_address_flag.should == 'Y' }
        it { deck.distribution_mail_code.should == '1' }
        it { deck.primary_borrower_id_number.should == '000000000000001' }
        it { deck.primary_borrower_home_telephone_country_code.should == '001' }
        it { deck.primary_borrower_work_telephone_country_code.should == '001' }

        it { deck.primary_borrower_home_telephone_number.should == '3335551212     ' }
        it { deck.primary_borrower_work_telephone_number.should == '1112223333     ' }

        it { deck.primary_borrower_country_code.should == "AUS" }
        it { deck.country_code_of_property.should == 'USA' }
      end
      context "when the country is not usa" do
        before { 
          secondary_borrower.residence.address = "123 Grove Street"
          secondary_borrower.residence.state = "OH"
          secondary_borrower.residence.city = 'Ann Arbor'
          secondary_borrower.residence.postal_code = 'CB1 9GJ'
          secondary_borrower.residence.country = 'United Arab Emirates'
          secondary_borrower.home_phone_num = '3335551212'
          secondary_borrower.employer.phone_num = '1112223333'

          mail_to = Master::MailTo.new({country: 'Canada', postal_code: 'A3B X4F'}, without_protection: true)
          secondary_borrower.stub(:mail_to).and_return(mail_to)
        }

        it { deck.secondary_borrower_id_number.should == '000000000000002' }
        it { deck.secondary_borrower_home_telephone_country_code.should == '001' }
        it { deck.secondary_borrower_work_telephone_country_code.should == '001' }

        it { deck.secondary_borrower_home_telephone_number.should == '3335551212     ' }
        it { deck.secondary_borrower_work_telephone_number.should == '1112223333     ' }

        it { deck.secondary_borrower_country_code.should == "CAN" }
      end
    end

  end

  describe 'secondary borrower address with mail_to entry' do
    before do
      mail_to = Master::MailTo.new({loan: loan, borrower_id: 'BRW2', street_address: '123 Acme Street',
        street_address_2: 'Suite #100', city: 'Howell', state: 'MI', postal_code: '48105'}, without_protection: true)
      secondary_borrower.stub(:mail_to).and_return(mail_to)
    end
    its '.mailing_address' do
      deck.secondary_borrower_mailing_address.should == "123 Acme St                        ".upcase
    end
    its '.mailing_address_2' do
      deck.secondary_borrower_mailing_address_2.should == "STE #100                           ".upcase
    end
    its '.mailing_city' do
      deck.secondary_borrower_mailing_city.should == "Howell               ".upcase
    end
    its '.mailing_state' do
      deck.secondary_borrower_mailing_state.should == 'MI'
    end
    its '.mailing_zip_code' do
      deck.secondary_borrower_mailing_zip_code.should == "48105     "
    end

  end

  describe 'populate coborrowers' do
    before do
      loan.property_address = "999 Foo Ave"
      loan.property_state = 'MI'
      loan.property_city = 'Ypsilanti'
      loan.property_postal_code = '1234567'
    end

    it 'test coborrower name' do
      deck.coborrower_name_1.should == "Borrower OMGHI Three JR  "
    end

    it 'test coborrower ssn' do
      deck.coborrower_ssn_1.should == '123121234'
    end

    context 'address variables primary and purchase and intent_to_occupy_type not Yes' do
      before do
        loan.purpose_type = 'Purchase'
        loan.property_usage_type = 'PrimaryResidence'

        tertiary_borrower.home_phone_num = "2485551212"
        tertiary_borrower.residence.address = "123 Grove Avenue "
        tertiary_borrower.residence.state = "OH"
        tertiary_borrower.residence.city = 'Ann Arbor'
        tertiary_borrower.residence.postal_code = '123442343'
      end
      it '@coborrower_home_phone_num_X' do
        deck.coborrower_phone_1.should == "12485551212"
      end
      it '@coborrower_mailing_address_X' do
        deck.coborrower_mailing_address_1.should == "123 Grove Ave                      ".upcase
      end
      it '@coborrower_mailing_address_X_2' do
        deck.coborrower_mailing_address_1_2.should == "                                   "
      end
      it '@coborrower_mailing_city_X' do
        deck.coborrower_mailing_city_1.should == "Ann Arbor            ".upcase
      end
      it '@coborrower_mailing_state_X' do
        deck.coborrower_mailing_state_1.should == 'OH'
      end
      it '@coborrower_mailing_zip_code_X' do
        deck.coborrower_mailing_zip_code_1.should == "12344-2343"
      end

      it "if street address is empty, don't populate address" do

        tertiary_borrower.residence.address = ""

        deck.coborrower_mailing_address_1.should == " "*35
        deck.coborrower_mailing_address_1_2.should == " "*35
        deck.coborrower_mailing_city_1.should  == " "*21
        deck.coborrower_mailing_state_1.should == " "*2
        deck.coborrower_mailing_zip_code_1.should == " "*10

      end
    end

    context 'address with mailto, non primary' do
      before do
        loan.property_usage_type = 'SecondHome'
        mail_to = Master::MailTo.new({loan: loan, borrower_id: 'BRW3', street_address: '123 Acme Street & Avenue ',
         street_address_2: 'Suite-100', city: 'Howell', state: 'MI', postal_code: '48105'}, without_protection: true)
        tertiary_borrower.stub(:mail_to).and_return(mail_to)
      end
      it '@coborrower_mailing_address_X' do
        deck.coborrower_mailing_address_1.should == "123 Acme Street & Ave              ".upcase
      end
      it '@coborrower_mailing_address_X_2' do
        deck.coborrower_mailing_address_1_2.should == "STE-100                            ".upcase
      end
      it '@coborrower_mailing_city_X' do
        deck.coborrower_mailing_city_1.should == "Howell               ".upcase
      end
      it '@coborrower_mailing_state_X' do
        deck.coborrower_mailing_state_1.should == 'MI'
      end
      it '@coborrower_mailing_zip_code_X' do
        deck.coborrower_mailing_zip_code_1.should == "48105     "
      end
    end

  end

  describe "misc calculations on card_deck" do
    describe "Calculating original_deferred_fee_amount" do
      it "Returns a negative number when it is a non-trid loan" do
        loan.stub(:is_portfolio_loan?).and_return(true)
        loan.stub(:trid_loan?).and_return(false)
        loan.stub(:original_deferred_fee_amount).and_return(5_000)
        expect(deck.original_deferred_fee_amount_5).to eql('-000500000')
        expect(deck.original_deferred_fee_amount).to eql('-000500000')
      end

      it "Returns a postiive number when it is a trid loan" do
        loan.stub(:is_portfolio_loan?).and_return(true)
        loan.stub(:trid_loan?).and_return(true)
        loan.stub(:original_deferred_fee_amount).and_return(5_000)
        expect(deck.original_deferred_fee_amount_5).to eql('000500000')
        expect(deck.original_deferred_fee_amount).to eql('000500000')
      end
    end

    describe "Setting default legal description for Mini-Corr" do
      it "Returns the proper legal string if one is set" do
        loan.stub_chain(:legal_descriptions, :select).and_return("FOO BAR LEGAL DESCRIPTION")
        allow_any_instance_of(Fiserv::CardDeck).to receive(:legal_description).and_return("FOO BAR LEGAL DESCRIPTION")
        expect(deck.legal_description).to match("FOO BAR LEGAL DESCRIPTION")
      end

      it "Returns the proper default legal string if none is set" do
        loan.stub_chain(:legal_descriptions, :select, :first).and_return(nil)
        expect(deck.legal_description).to match("SEE EXHIBIT A ATTACHED HERETO AND BY THIS REFERENCE MADE A PART HERE OF.")
      end

    end
  end


  class FakeTranslatorFactory
    def build_translator_for(loan)
      @existing_translators ||= {}
      @existing_translators[loan] ||= FakeTranslator.new loan
      x = @existing_translators[loan]
      x
    end
  end

  class FakeTranslator
    attr_accessor :loan

    def initialize loan
      self.loan = loan
    end

    def method_missing(symbol)
      loan.send symbol
    end

    def loan_type_number; '0'; end

    def alternative_mortgage_indicator; '0'; end

    def loan_serv_product_code
      'a'
    end

    def state_code
      '01'
    end

    def property_type
      16
    end

    def branch

    end

    def purpose
      15
    end

    def application_purpose
      11
    end

    def pmi_company_code
      '01'
    end

    def primary_gender
      'N'
    end

    def primary_ethnicity
      4
    end

    def primary_race
      1
    end

    def primary_marital_status
      'M'
    end

    def secondary_gender
      'N'
    end

    def secondary_ethnicity
      4
    end

    def secondary_race
      1
    end

    def secondary_marital_status
      'M'
    end

    def asset_type_code
      4
    end

    def down_payment_type_code
      'H'
    end

    def flood_program_code
      'A'
    end
  end

  def build_fake_borrower opts
    b = Master::Person::Borrower.new opts, without_protection: true
    b.stub employer: Master::Employer.new
    b.stub residence: Master::Residence.new
    b.stub income_sources: []
    b
  end

  def build_hudline(opts={})
    Master::HudLine.new opts, without_protection: true
  end


end
