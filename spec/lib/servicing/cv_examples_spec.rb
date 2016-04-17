require 'spec_helper'
require_relative 'have_card_matching'

describe "CV cards" do
  let(:loan) do 
    Master::Loan.new.tap do |loan|
      loan.product_name = 'C30FXD'
      loan.extend Servicing::FiservDataSource
    end
  end
  let(:cards) { loan.escrow_disbursement_containers }

  describe "CV Cards with letter types" do
    describe "A monthly wind escrow 1008 hud line" do
      before do 
        hud_line line_num: 1008, user_defined_fee_name: 'wind', monthly_amount: 1000.01
        escrow item_type: 'Other', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
      end

      it "should have one card" do
        cards.size.should == 1
      end

      it "should have an H3 card with stuff and letter type" do
        allow_any_instance_of(Servicing::DisbursementInfoBuilderBase).to receive(:net_fee_indicator).and_return(true)
        expect(cards).to have_a_card_matching(
          type: 'H', 
          type_qualifier: '3', 
          certificate_identifier: '999999993',
          count: 12,
          date: Date.new(2013, 1, 31),
          expiration_date: Date.new(2013, 1, 31),
          amount: 1000.01,
          coverage_amount: nil,
          coverage_code: ' ',
          payee_code_prefix: '9999',
          payee_code_suffix: '99993'
        )
      end

      it "should have an H3 card with stuff and numeric type" do
        allow_any_instance_of(Servicing::DisbursementInfoBuilderBase).to receive(:net_fee_indicator).and_return(false)
        expect(cards).to have_a_card_matching(
          type: 2, 
          type_qualifier: '3', 
          certificate_identifier: '999999993',
          count: 12,
          date: Date.new(2013, 1, 31),
          expiration_date: Date.new(2013, 1, 31),
          amount: 1000.01,
          coverage_amount: nil,
          coverage_code: ' ',
          payee_code_prefix: '9999',
          payee_code_suffix: '99993'
        )
      end

    end
  end

  describe "expiration dates" do
    let(:the_date) { Date.new(2012, 2, 2) }
    before do
      Date.stub today: the_date - 1.day
    end

    [ ['FloodInsurance', 1007, nil ],
      ['HazardInsurance', 1002, nil ],
      ['Other', 1008, 'wind' ],
    ].each do |item_type, hud_line_num, user_defined_fee_name|
      describe "for insurance #{hud_line_num} #{item_type}" do
        before do
          hud_line line_num: hud_line_num, user_defined_fee_name: user_defined_fee_name
          escrow item_type: item_type, payment_frequency_type: 'Monthly', due_date: the_date
          disbursement_type disbursement_type: item_type
        end

        it "should match the due date" do
          expect(cards).to have_a_card_matching(expiration_date: the_date)
        end
      end
    end

    [ ['Assessment', 1006, nil ],
      ['CountyPropertyTax', 1005, nil ],
      ['CityPropertyTax', 1004, nil ],
      ['Other', 1008, 'village' ],
      ['Other', 1008, 'sewer' ],
      ['Other', 1008, 'school' ],
    ].each do |item_type, hud_line_num, user_defined_fee_name|
      describe "for taxes #{hud_line_num} #{item_type}" do
        before do
          hud_line line_num: hud_line_num, user_defined_fee_name: user_defined_fee_name
          escrow item_type: item_type, payment_frequency_type: 'Monthly', due_date: the_date
          disbursement_type disbursement_type: item_type
        end

        it "should not set expiration date" do
          expect(cards).to have_a_card_matching(expiration_date: nil)
        end
      end
    end

    describe "for mortgage insurance" do
      before do
        hud_line line_num: 1003
        escrow item_type: 'MortgageInsurance', payment_frequency_type: 'Monthly', due_date: the_date
        disbursement_type disbursement_type: 'MortgageInsurance'
      end
      # context "lender paid" do
      #   before do
      #     loan.lender_paid_mi = true
      #     loan.closing_on = Date.new(2010, 1, 2)
      #   end

      #   it "should be one year after closing" do
      #     expect(cards).to have_a_card_matching(expiration_date: Date.new(2011, 1, 2))
      #   end
      # end

      context "FHA" do

      end

      context "conventional" do

      end
    end

  end


  describe "hazard insurance dummy card" do
    context "when there is a hud line for hazard insurance" do
      before { hud_line line_num: 1002 }
      it "should not have a dummy hazard insurance card" do
        expect(cards).not_to have_a_card_matching(name: 'hazard_insurance')
      end
    end

    context "when there is no hud line for hazard insurance" do
      context "when lender paid MI" do
        before { loan.stub lender_paid_mi: true }
        it "should have a dummy card for hazard insurance" do
          expect(cards).to have_a_card_matching(
            name: 'hazard_insurance',
            count: 12,
            type: '2',
            type_qualifier: '0',
            certificate_identifier: '999999993',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993',
          )
        end
      end

      context "when not lender paid MI" do
        before { loan.stub lender_paid_mi: false }
        it "should not have any hazard insurance card" do
          expect(cards).not_to have_a_card_matching(name: 'hazard_insurance')
        end
      end
    end
  end

  describe "dummy flood insurance card" do

    shared_examples_for "has a dummy flood card" do
      context "for a condo" do
        before { loan.stub :is_condo? => true }

        it "should have a dummy flood card" do
          expect(cards).to have_a_card_matching(
            name: 'Dummy_Flood_Insurance',
            count: 12,
            months: [ 0, 0, 0, 0, ],
            type: 'H',
            amount: 0,
            type_qualifier: '7',
            certificate_identifier: '999999993',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993',
            coverage_code: ' ',
            coverage_amount: nil,
          )
        end
      end

      context "not for a condo" do
        before { loan.stub :is_condo? => false }

        it "should have a dummy flood card" do
          expect(cards).to have_a_card_matching(
            name: 'Dummy_Flood_Insurance',
            type_qualifier: '2',
          )
        end
      end

      context "with a flood insurance policy number" do
        before { loan.stub flood_insurance_policy_number: 'ABCDE' }

        it "should have a dummy flood card" do
          expect(cards).to have_a_card_matching(
            name: 'Dummy_Flood_Insurance',
            certificate_identifier: 'ABCDE',
          )
        end
      end
    end

    context "when no special flood hazard indicator" do
      before { loan.stub special_flood_hazard_area_indicator: false }
      it "should not have a dummy flood card" do
        expect(cards).not_to have_a_card_matching(name: 'Dummy_Flood_Insurance')
      end
    end
    context "when there is a special flood hazard indicator" do
      before { loan.stub special_flood_hazard_area_indicator: true }
      context "when there is no flood-like hud line" do
        it_behaves_like "has a dummy flood card"
      end

      context "when there is a 1007 line with a value" do
        before { hud_line line_num: 1007, monthly_amount: 123 }
        it "should not have a dummy flood card" do
          expect(cards).not_to have_a_card_matching(name: 'Dummy_Flood_Insurance')
        end
      end

      context "when there is a 1007 line with no value" do
        before { hud_line line_num: 1007, monthly_amount: 0 }
        it_behaves_like "has a dummy flood card"
      end

      [1008, 1009].each do |line_num|
        context "when there is a #{line_num} line matching flood and a value" do
          before { hud_line line_num: line_num, user_defined_fee_name: 'foo flood bar', monthly_amount: 123 }
          it "should not have a dummy flood card" do
            expect(cards).not_to have_a_card_matching(name: 'Dummy_Flood_Insurance')
          end
        end

        context "when there is a #{line_num} line matching flood with no value" do
          before { hud_line line_num: line_num, user_defined_fee_name: 'foo flood bar', monthly_amount: 0 }
          it_behaves_like "has a dummy flood card"
        end

        context "when there is a #{line_num} line not matching flood with a value" do
          before { hud_line line_num: line_num, user_defined_fee_name: 'wind', monthly_amount: 123 }
          it_behaves_like "has a dummy flood card"
        end
      end
    end
  end

  describe "h6 dummy hazard card" do
    shared_examples_for "has a 26 dummy hazard card" do
      it "should have a 26 dummy hazard card" do
        expect(cards).to have_a_card_matching(
          name: 'Dummy_Hazard_Insurance',
          count: 12,
          type: '2',
          type_qualifier: '6',
          certificate_identifier: 999_999_993,
          payee_code_prefix: '9999',
          payee_code_suffix: '99993',
        )
      end
    end
    shared_examples_for "has a H6 dummy hazard card" do
      it "should have a 26 dummy hazard card" do
        expect(cards).to have_a_card_matching(
          name: 'Dummy_Hazard_Insurance',
          count: 12,
          type: '2',
          type_qualifier: '6',
          certificate_identifier: 999_999_993,
          payee_code_prefix: '9999',
          payee_code_suffix: '99993',
        )
      end
    end

    context "for a condo" do
      before { loan.stub :is_condo? => true }
      
      context "when there are no hazard hud lines" do
        it_behaves_like "has a 26 dummy hazard card"
      end

      context "when there is a 1002 hazard hud line with value" do
        before { hud_line line_num: 1002, monthly_amount: 123 }
        it_behaves_like "has a H6 dummy hazard card"
        it "should also have a normal hazard card" do
          expect(cards).to have_a_card_matching(name: 'hazard_insurance')
        end
      end

      [1008, 1009].each do |line_num|
        context "when there is a #{line_num} hazard hud line with value" do
          before { hud_line line_num: line_num, user_defined_fee_name: 'a hazard b', monthly_amount: 123 }
          it_behaves_like "has a H6 dummy hazard card"
        end

        context "when there is a #{line_num} hazard hud line with no value" do
          before { hud_line line_num: line_num, user_defined_fee_name: 'a hazard b', monthly_amount: 0 }
          it_behaves_like "has a 26 dummy hazard card"
        end

        context "when there is a #{line_num} nonhazard hud line with value" do
          before { hud_line line_num: line_num, user_defined_fee_name: 'a b', monthly_amount: 123 }
          it_behaves_like "has a 26 dummy hazard card"
        end
      end
    end

    context "when it is not a condo" do
      before { loan.stub :is_condo? => false }

      it "should not have any dummy hazard card" do
        expect(cards).not_to have_a_card_matching(name: 'Dummy_Hazard_Insurance')
      end
    end
  end

  describe "post trid loans" do
    describe "ALWAYS letter types" do
      before do
        loan.stub trid_loan?: true
        allow_any_instance_of(Servicing::DisbursementInfoBuilderBase).to receive(:net_fee_indicator).and_return(false)
      end

      context "when there is a hud_line with Flood Insurance and matching escrow" do
        before do 
          hud_line system_fee_name: 'Flood Insurance', monthly_amount: 1000.01
          escrow item_type: 'FloodInsurance', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an flood_insurance card (condo)" do
          loan.stub :is_condo? => true

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '7', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end

        it "should have an flood_insurance card (not condo)" do
          loan.stub :is_condo? => false

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '2', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end
      end

      context "when there is a hud_line with Flood Ins. - Gap and matching escrow" do
        before do 
          hud_line system_fee_name: 'Flood Ins. - Gap', monthly_amount: 1000.01
          escrow item_type: 'FloodInsurance', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an flood_insurance card (condo)" do
          loan.stub :is_condo? => true

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '7', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end

        it "should have an flood_insurance card (not condo)" do
          loan.stub :is_condo? => false

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '2', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end
      end

      context "When there are multiple flood insurance cards" do
        before do 
          hud_line system_fee_name: 'Flood Ins. - Gap', monthly_amount: 1000.01
          escrow item_type: 'FloodInsurance', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
          hud_line system_fee_name: 'Flood Insurance', monthly_amount: 1000.01
          escrow item_type: 'FloodInsurance', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have two cards" do
          cards.size.should == 2
        end

        it "should have the proper cards (condo)" do
          loan.stub :is_condo? => true

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '7', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '7', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end

        it "should have the proper cards (not condo)" do
          loan.stub :is_condo? => false

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '2', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '2', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end
      end

    end

    describe "CV Cards with letter types" do

      before do
        loan.stub trid_loan?: true
        allow_any_instance_of(Servicing::DisbursementInfoBuilderBase).to receive(:net_fee_indicator).and_return(true)
      end

      context "when there is a hud_line with Annual Assessments and matching escrow" do
        before do 
          hud_line system_fee_name: 'Annual Assessments', monthly_amount: 1000.01
          escrow item_type: 'TownPropertyTax', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an annual_assessments card" do
          expect(cards).to have_a_card_matching(
            name: 'annual_assessments',
            type: 'T', 
            type_qualifier: '3', 
            certificate_identifier: '999999991',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: nil,
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '0999',
            payee_code_suffix: '09991'
          )
        end
      end

      context "when there is a hud_line with City Taxes and matching escrow" do
        before do 
          hud_line system_fee_name: 'City Taxes', monthly_amount: 1000.01
          escrow item_type: 'CityPropertyTax', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an city_property_tax card" do
          expect(cards).to have_a_card_matching(
            name: 'city_property_tax',
            type: 'T', 
            type_qualifier: '1', 
            certificate_identifier: '999999991',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: nil,
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '0999',
            payee_code_suffix: '09991'
          )
        end
      end

      context "when there is a hud_line with County Taxes and matching escrow" do
        before do 
          hud_line system_fee_name: 'County Taxes', monthly_amount: 1000.01
          escrow item_type: 'CountyPropertyTax', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an county_property_tax card" do
          expect(cards).to have_a_card_matching(
            name: 'county_property_tax',
            type: 'T', 
            type_qualifier: '0', 
            certificate_identifier: '999999991',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: nil,
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '0999',
            payee_code_suffix: '09991'
          )
        end
      end

      context "when there is a hud_line with Earthquake Insurance and matching escrow" do
        before do 
          hud_line system_fee_name: 'Earthquake Insurance', monthly_amount: 1000.01
          escrow item_type: 'EarthquakeInsurance', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an earthquake_insurance card" do
          expect(cards).to have_a_card_matching(
            name: 'earthquake',
            type: 'H', 
            type_qualifier: '4', 
            certificate_identifier: '999999991',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '0999',
            payee_code_suffix: '09991'
          )
        end
      end

      context "when there is a hud_line with Flood Insurance and matching escrow" do
        before do 
          hud_line system_fee_name: 'Flood Insurance', monthly_amount: 1000.01
          escrow item_type: 'FloodInsurance', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an flood_insurance card (condo)" do
          loan.stub :is_condo? => true

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '7', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end

        it "should have an flood_insurance card (not condo)" do
          loan.stub :is_condo? => false

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '2', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end
      end

      context "when there is a hud_line with Flood Ins. - Gap and matching escrow" do
        before do 
          hud_line system_fee_name: 'Flood Ins. - Gap', monthly_amount: 1000.01
          escrow item_type: 'FloodInsurance', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an flood_insurance card (condo)" do
          loan.stub :is_condo? => true

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '7', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end

        it "should have an flood_insurance card (not condo)" do
          loan.stub :is_condo? => false

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '2', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end
      end

      context "When there are multiple flood insurance cards" do
        before do 
          hud_line system_fee_name: 'Flood Ins. - Gap', monthly_amount: 1000.01
          escrow item_type: 'FloodInsurance', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
          hud_line system_fee_name: 'Flood Insurance', monthly_amount: 1000.01
          escrow item_type: 'FloodInsurance', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have two cards" do
          cards.size.should == 2
        end

        it "should have the proper cards (condo)" do
          loan.stub :is_condo? => true

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '7', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '7', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end

        it "should have the proper cards (not condo)" do
          loan.stub :is_condo? => false

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '2', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )

          expect(cards).to have_a_card_matching(
            name: 'flood_insurance',
            type: 'H', 
            type_qualifier: '2', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end
      end

      context "when there is a hud_line with Homeowners Insurance and matching escrow" do
        before do 
          hud_line system_fee_name: 'Homeowners Insurance', monthly_amount: 1000.01
          escrow item_type: 'HazardInsurance', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have a hazard_insurance card (not condo)" do
          loan.stub :is_condo? => false

          expect(cards).to have_a_card_matching(
            name: 'hazard_insurance',
            type: 'H', 
            type_qualifier: '0', 
            certificate_identifier: nil,
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end

        it "should have a hazard_insurance card (condo)" do
          loan.stub :is_condo? => true

          expect(cards).to have_a_card_matching(
            name: 'hazard_insurance',
            type: 'Z', 
            type_qualifier: '7', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end

      end

      context "when there is a hud_line with Hurricane Insurance and matching escrow" do
        before do 
          hud_line system_fee_name: 'Hurricane Insurance', monthly_amount: 1000.01
          escrow item_type: 'StormInsurance', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an storm_insurance card (non condo)" do
          loan.stub :is_condo? => false
          expect(cards).to have_a_card_matching(
            name: 'storm_insurance',
            type: 'H', 
            type_qualifier: '3', 
            certificate_identifier: '999999991',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '0999',
            payee_code_suffix: '09991'
          )
        end

        it "should have an storm_insurance card (condo)" do
          loan.stub :is_condo? => true
          expect(cards).to have_a_card_matching(
            name: 'storm_insurance',
            type: 'H', 
            type_qualifier: '8', 
            certificate_identifier: '999999991',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '0999',
            payee_code_suffix: '09991'
          )
        end

      end

      context "when there is a hud_line with Mortgage Insurance and matching escrow" do
        before do 
          hud_line system_fee_name: 'Mortgage Insurance', monthly_amount: 1000.01
          escrow item_type: 'MortgageInsurance', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
          #disbursement_type disbursement_type: 'MortgageInsurance'
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an mortgage_insurance card (non fha)" do
          expect(cards).to have_a_card_matching(
            name: 'mortgage_insurance',
            type: 'P', 
            type_qualifier: '0', 
            certificate_identifier: '',
            count: 12,
            date: Date.new(2012, 12, 31),
            expiration_date: nil,
            amount: 1000.01,
            coverage_amount: 0,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99901'
          )
        end

        it "should have an mortgage_insurance card (fha)" do
          loan.stub :mortgage_type => 'FHA'

          expect(cards).to have_a_card_matching(
            name: 'mortgage_insurance',
            type: 'R', 
            type_qualifier: ' ', 
            certificate_identifier: 'FR',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: nil,
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '0213',
            payee_code_suffix: '56000'
          )
        end

      end

      context "when there is a hud_line with Other Insurance and matching escrow" do
        before do 
          hud_line system_fee_name: 'Other Insurance', monthly_amount: 1000.01
          escrow item_type: 'Other', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an other card (non condo)" do
          loan.stub :is_condo? => false

          expect(cards).to have_a_card_matching(
            name: 'other',
            type: 'H', 
            type_qualifier: '0', 
            certificate_identifier: '999999991',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '0999',
            payee_code_suffix: '09991'
          )
        end

        it "should have an other card (condo)" do
          loan.stub :is_condo? => true

          expect(cards).to have_a_card_matching(
            name: 'other',
            type: 'Z', 
            type_qualifier: '0', 
            certificate_identifier: '999999991',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '0999',
            payee_code_suffix: '09991'
          )
        end

      end

      context "when there is a hud_line with Property Taxes and matching escrow" do
        before do 
          hud_line system_fee_name: 'Property Taxes', monthly_amount: 1000.01
          escrow item_type: 'StatePropertyTax', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an county_property_tax card" do
          expect(cards).to have_a_card_matching(
            name: 'county_property_tax',
            type: 'T', 
            type_qualifier: '0', 
            certificate_identifier: '999999991',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: nil,
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '0999',
            payee_code_suffix: '09991'
          )
        end
      end

      context "when there is a hud_line with School Taxes and matching escrow" do
        before do 
          hud_line system_fee_name: 'School Taxes', monthly_amount: 1000.01
          escrow item_type: 'DistrictPropertyTax', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an school card" do
          expect(cards).to have_a_card_matching(
            name: 'school',
            type: 'T', 
            type_qualifier: '4', 
            certificate_identifier: '999999991',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: nil,
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '0999',
            payee_code_suffix: '09991'
          )
        end
      end

      context "when there is a hud_line with Village Taxes and matching escrow" do
        before do 
          hud_line system_fee_name: 'Village Taxes', monthly_amount: 1000.01
          escrow item_type: 'TownshipPropertyTax', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an village card" do
          expect(cards).to have_a_card_matching(
            name: 'village',
            type: 'T', 
            type_qualifier: '2', 
            certificate_identifier: '999999991',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: nil,
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '0999',
            payee_code_suffix: '09991'
          )
        end
      end

      context "when there is a hud_line with Wind Insurance and matching escrow" do
        before do 
          hud_line system_fee_name: 'Wind Insurance', monthly_amount: 1000.01
          escrow item_type: 'WindstormInsurance', payment_frequency_type: 'Monthly', due_date: Date.new(2013, 1, 31)
        end

        it "should have one card" do
          cards.size.should == 1
        end

        it "should have an wind card (non condo)" do
          loan.stub :is_condo? => false

          expect(cards).to have_a_card_matching(
            name: 'wind',
            type: 'H', 
            type_qualifier: '3', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end

        it "should have an wind card (non condo)" do
          loan.stub :is_condo? => true

          expect(cards).to have_a_card_matching(
            name: 'wind',
            type: 'H', 
            type_qualifier: '8', 
            certificate_identifier: '999999993',
            count: 12,
            date: Date.new(2013, 1, 31),
            expiration_date: Date.new(2013, 1, 31),
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end

      end

      context "when it is missing data" do
        it "should default to 12 for count when no payment_frequency_type set" do
          hud_line system_fee_name: 'Wind Insurance', monthly_amount: 1000.01
          escrow item_type: 'WindstormInsurance', payment_frequency_type: nil, due_date: nil

          loan.stub :is_condo? => false

          expect(cards).to have_a_card_matching(
            name: 'wind',
            type: 'H', 
            type_qualifier: '3', 
            certificate_identifier: '999999993',
            count: 12,
            date: nil,
            expiration_date: nil,
            amount: 1000.01,
            coverage_amount: nil,
            coverage_code: ' ',
            payee_code_prefix: '9999',
            payee_code_suffix: '99993'
          )
        end
      end
    end
  end

  def hud_line(opts)
    defaults = {
      "hud_type" => 'HUD',
      "monthly_amount" => 1, 
      "num_months" => 12,
    }
    loan.hud_lines << Master::HudLine.new(defaults.merge(opts), without_protection: true)
  end

  def escrow(opts={})
    defaults = {
      'collected_number_of_months_count' => 12,
      'item_type' => 'Other'
    }
    loan.escrows << Master::Escrow.new(defaults.merge(opts), without_protection: true)
  end

  def disbursement_type(opts={})
    loan.escrow_disbursement_types << Master::EscrowDisbursementType.new(opts, without_protection: true)
  end

  def proposed_housing_expense(opts)
    loan.proposed_housing_expenses << Master::ProposedHousingExpense.new(opts, without_protection: true)
  end


end
