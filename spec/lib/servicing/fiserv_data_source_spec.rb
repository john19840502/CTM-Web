require 'spec_helper' #you can get rid of this if you get rid of references to Master::Loan
require 'servicing/fiserv_data_source'

describe Servicing::FiservDataSource do

  let(:loan) { Master::Loan.new }
  let(:container) { loan.escrow_disbursement_containers.find{|ed| ed.name == name }}
  let(:primary_borrower) { build_fake_borrower borrower_id: 'BRW1' }
  let(:secondary_borrower) { build_fake_borrower borrower_id: 'BRW2' }

  before do
    loan.extend Servicing::FiservDataSource

    brws = [primary_borrower, secondary_borrower]
    brws.stub primary: primary_borrower
    brws.stub secondary: secondary_borrower
    brws.stub coborrowers: []
    loan.stub borrowers: brws

    hud_lines = []
    hud_lines.stub(:hud) { hud_lines.select{|line| line.hud_type == 'HUD'}}
    hud_lines.stub(:gfe) { hud_lines.select{|line| line.hud_type == 'GFE'}}
    loan.stub hud_lines: hud_lines

    proposed_housing_expenses = []
    loan.stub proposed_housing_expenses: proposed_housing_expenses

    payment_occurrences = []
    loan.stub payment_occurrences: payment_occurrences

    liabilities = []
    loan.stub liabilities: liabilities

    assets = []
    loan.stub assets: assets

    loan.stub is_fha?: false
    loan.base_loan_amount = 100_000
  end

  shared_examples_for "expiration date" do
    describe "expiration_date" do
      before do
        Date.stub today: Date.new(2012, 2, 2)
        add_escrow(loan, {item_type: disbursement_type, payment_frequency_type: 'Monthly'})
      end
      it "expiration date should be next due date for hazard insurance" do
        if type_flag == 'H'
          container.expiration_date.should == container.date
        end
      end
      it "expiration date should be nil for taxes" do
        if type_flag == 'T'
          container.expiration_date.should == nil
        end
      end
    end
  end

  shared_examples_for "payee code" do

    describe "payee codes" do
      before do
        add_escrow(loan, {item_type: disbursement_type, payment_frequency_type: 'Monthly'})
      end
      it "dummy payee codes for hazard insurance" do
        if type_flag == 'H'
          container.payee_code_prefix.should == '9999'
          container.payee_code_suffix.should == '99993'
        end
      end
      it "dummy payee codes for taxes" do
        if type_flag == 'T'
          container.payee_code_prefix.should == '0999'
          container.payee_code_suffix.should == '09991'
        end
      end
    end
  end

  shared_examples_for "next payment months" do
    before do
      loan.escrow_disbursement_types.clear
      Date.stub today: Date.new(2012, 2, 2)
    end
    it "when the frequency is monthly, all next pmt months are zero" do
      loan.escrows << build_escrow(item_type: disbursement_type, due_date: Date.new(2012, 2, 7), payment_frequency_type: 'Monthly', collected_number_of_months_count: 12)
      loan.escrow_disbursement_types << build_escrow_disbursement_type(reference_id: 123, disbursement_type: disbursement_type, frequency: 'Monthly')
      loan.hud_lines << build_hudline(line_num: Array(Master::HudLine::LINE_NUMBER_LOOKUP[disbursement_type.underscore.to_sym]).first, hud_type: 'HUD', monthly_amount: 1, num_months: 12)
      container.months.should == [0, 0, 0, 0]
    end

    it "when the frequency is quarterly, next pmt months are based on next pmt date" do
      loan.escrows << build_escrow(item_type: disbursement_type, due_date: Date.new(2012, 7, 2), second_due_date: Date.new(2012, 9, 2), third_due_date: Date.new(2013, 2, 2), fourth_due_date: Date.new(2013, 4, 2), payment_frequency_type: 'Quarterly', collected_number_of_months_count: 12)
      loan.escrow_disbursement_types << build_escrow_disbursement_type(reference_id: 123, disbursement_type: disbursement_type, frequency: 'Quarterly')
      loan.escrow_disbursements << build_escrow_disbursement(reference_id: 123, payment_scheduled_on: Date.new(2012, 7, 2))
      loan.hud_lines << build_hudline(line_num: Array(Master::HudLine::LINE_NUMBER_LOOKUP[disbursement_type.underscore.to_sym]).first, hud_type: 'HUD', monthly_amount: 1, num_months: 12)
      container.months.should == [7, 9, 2, 4]
    end

    it "when the frequency is annual, do the right values" do
      loan.escrows << build_escrow(item_type: disbursement_type, due_date: Date.new(2012, 7, 2), payment_frequency_type: 'Annual', collected_number_of_months_count: 12)
      loan.escrow_disbursement_types << build_escrow_disbursement_type(reference_id: 123, disbursement_type: disbursement_type, frequency: 'Annual')
      loan.escrow_disbursements << build_escrow_disbursement(reference_id: 123, payment_scheduled_on: Date.new(2012, 7, 2))
      loan.hud_lines << build_hudline(line_num: Array(Master::HudLine::LINE_NUMBER_LOOKUP[disbursement_type.underscore.to_sym]).first, hud_type: 'HUD', monthly_amount: 1, num_months: 12)
      container.months.should == [7, 0, 0, 0]
    end

    it "when the frequency is semiannual, do the right values" do
      loan.escrows << build_escrow(item_type: disbursement_type, due_date: Date.new(2012, 7, 2), second_due_date: Date.new(2013, 2, 2), payment_frequency_type: 'SemiAnnual', collected_number_of_months_count: 12)
      loan.escrow_disbursement_types << build_escrow_disbursement_type(reference_id: 123, disbursement_type: disbursement_type, frequency: 'SemiAnnual')
      loan.escrow_disbursements << build_escrow_disbursement(reference_id: 123, payment_scheduled_on: Date.new(2012, 7, 2))
      loan.hud_lines << build_hudline(line_num: Array(Master::HudLine::LINE_NUMBER_LOOKUP[disbursement_type.underscore.to_sym]).first, hud_type: 'HUD', monthly_amount: 1, num_months: 12)
      container.months.should == [7, 2, 0, 0]
    end

    it "when the frequency is annual and the next payment date is missing, don't crash" do
      loan.escrows << build_escrow(item_type: disbursement_type, payment_frequency_type: 'Annual', collected_number_of_months_count: 12)
      loan.escrow_disbursement_types << build_escrow_disbursement_type(reference_id: 123, disbursement_type: disbursement_type, frequency: 'Annual')
      loan.escrow_disbursements << build_escrow_disbursement(reference_id: 123, payment_scheduled_on: nil)
      loan.hud_lines << build_hudline(line_num: Array(Master::HudLine::LINE_NUMBER_LOOKUP[disbursement_type.underscore.to_sym]).first, hud_type: 'HUD', monthly_amount: 1, num_months: 12)
      container.months.should == nil
    end
  end

  shared_examples_for "disbursement count" do
    before do
      loan.escrow_disbursement_types.clear
      loan.escrow_disbursement_types << build_escrow_disbursement_type(
        disbursement_type: 'Something Else', frequency: 'Daily')
      loan.escrows << build_escrow(item_type: 'Something Else', payment_frequency_type: 'Daily') 
    end

    it "Monthly disbursement should have count 12" do
      loan.hud_lines << build_hudline(line_num: Array(Master::HudLine::LINE_NUMBER_LOOKUP[disbursement_type.underscore.to_sym]).first, hud_type: 'HUD', monthly_amount: 1, num_months: 12)
      loan.escrows << build_escrow(item_type: disbursement_type, payment_frequency_type: 'Monthly', collected_number_of_months_count: 12)
      loan.escrow_disbursement_types << build_escrow_disbursement_type(disbursement_type: disbursement_type, frequency: 'Monthly')
      container.count.should == 12
      container.amount.to_f.should == 12 / container.count
    end

    it "quarterly disbursement should have count 4" do
      loan.hud_lines << build_hudline(line_num: Array(Master::HudLine::LINE_NUMBER_LOOKUP[disbursement_type.underscore.to_sym]).first, hud_type: 'HUD', monthly_amount: 1, num_months: 12)
      loan.escrows << build_escrow(item_type: disbursement_type, payment_frequency_type: 'Quarterly', collected_number_of_months_count: 12)
      loan.escrow_disbursement_types << build_escrow_disbursement_type(disbursement_type: disbursement_type, frequency: 'Quarterly')
      container.count.should == 4
      container.amount.to_f.should == 12 / container.count
    end

    it "annual disbursement should have count 1" do
      loan.hud_lines << build_hudline(line_num: Array(Master::HudLine::LINE_NUMBER_LOOKUP[disbursement_type.underscore.to_sym]).first, hud_type: 'HUD', monthly_amount: 1, num_months: 12)
      loan.escrows << build_escrow(item_type: disbursement_type, payment_frequency_type: 'Annual', collected_number_of_months_count: 12)
      loan.escrow_disbursement_types << build_escrow_disbursement_type(disbursement_type: disbursement_type, frequency: 'Annual')
      container.count.should == 1
      container.amount.to_f.should == 12 / container.count
    end

    it "semi-annual disbursement should have count 2" do
      loan.hud_lines << build_hudline(line_num: Array(Master::HudLine::LINE_NUMBER_LOOKUP[disbursement_type.underscore.to_sym]).first, hud_type: 'HUD', monthly_amount: 1, num_months: 12)
      loan.escrows << build_escrow(item_type: disbursement_type, payment_frequency_type: 'SemiAnnual', collected_number_of_months_count: 12)
      loan.escrow_disbursement_types << build_escrow_disbursement_type(disbursement_type: disbursement_type, frequency: 'SemiAnnual')
      container.count.should == 2
      container.amount.to_f.should == 12 / container.count
    end

    it "tri-annual disbursement should have count 3" do
      loan.hud_lines << build_hudline(line_num: Array(Master::HudLine::LINE_NUMBER_LOOKUP[disbursement_type.underscore.to_sym]).first, hud_type: 'HUD', monthly_amount: 1, num_months: 12)
      loan.escrows << build_escrow(item_type: disbursement_type, payment_frequency_type: 'TriAnnual', collected_number_of_months_count: 12)
      loan.escrow_disbursement_types << build_escrow_disbursement_type(disbursement_type: disbursement_type, frequency: 'SemiAnnual')
      container.count.should == 3
      container.amount.to_f.should == 12 / container.count
    end
  end

  shared_examples_for "payment amount" do

    it "should be the annual HI payment amount divided by the count" do
      loan.escrows << build_escrow(item_type: disbursement_type, payment_frequency_type: 'Monthly', collected_number_of_months_count: 12)
      loan.escrow_disbursement_types << build_escrow_disbursement_type(disbursement_type: disbursement_type, frequency: 'Monthly')
      loan.hud_lines.clear
      loan.hud_lines << build_hudline(line_num: Array(Master::HudLine::LINE_NUMBER_LOOKUP[disbursement_type.underscore.to_sym]).first, hud_type: 'HUD', monthly_amount: 8333.29, num_months: 12, user_defined_fee_name: "foo #{name} bar")
      container.amount.to_f.should == 8333.29
    end
  end

  # 10/03/2014 [IR] - Since we are not using multiple EscrowDisbursement records any more this should be straight 
  # forward. Just use the due_date field on escrows
  shared_examples_for "payment date" do
    it "should be the soonest future payment date" do
      Date.stub today: Date.new(2012, 2, 2)
      loan.escrows << build_escrow(item_type: disbursement_type, due_date: Date.new(2012, 2, 7), collected_number_of_months_count: 12)
      loan.hud_lines << build_hudline(line_num: Array(Master::HudLine::LINE_NUMBER_LOOKUP[disbursement_type.underscore.to_sym]).first, hud_type: 'HUD', monthly_amount: 1, num_months: 12)

      #loan.escrows << build_escrow(item_type: disbursement_type, due_date: Date.new(2012, 2, 7))
      #loan.escrows << build_escrow(item_type: disbursement_type, due_date: Date.new(2012, 2, 9))
      #loan.escrows << build_escrow(item_type: disbursement_type, due_date: Date.new(2012, 2, 4))
      
      #loan.escrow_disbursement_types << Master::EscrowDisbursementType.new(
      #  disbursement_type: disbursement_type, reference_id: 123)
      #loan.escrow_disbursements << Master::EscrowDisbursement.new(
      #  reference_id: 123, payment_scheduled_on: Date.new(2012, 2, 1))
      #loan.escrow_disbursements << Master::EscrowDisbursement.new(
      #  reference_id: 123, payment_scheduled_on: Date.new(2012, 2, 7))
      #loan.escrow_disbursements << Master::EscrowDisbursement.new(
      #  reference_id: 123, payment_scheduled_on: Date.new(2012, 2, 9))
      #loan.escrow_disbursements << Master::EscrowDisbursement.new(
      #  reference_id: 222, payment_scheduled_on: Date.new(2012, 2, 4))

      container.date.should == Date.new(2012, 2, 7)
    end
  end

  shared_examples_for "disbursment type for non-escrowed lines" do
    describe "numeric escrow disbursement type codes" do
      before do
        loan.escrow_waiver_indicator = true
        add_escrow(loan, {item_type: disbursement_type})
      end

      it "for hazard insurance should be 2" do
        if type_flag == 'H' && disbursement_type.eql?('hazard_insurance')
          container.type.should == '2'
        end
      end
      it "for taxes should be 9" do
        if type_flag == 'T' && disbursement_type =~ /tax|assestment/
          container.type.should == '9'
        end
      end

      it "for hazard insurance the payee codes should be 9999 and 99993" do
        if type_flag == 'H' && disbursement_type.eql?('hazard_insurance')
          container.type.should == '2'
          container.payee_code_prefix.should == '9999'
          container.payee_code_suffix.should == '99993'
        end
      end
      it "for taxes the payee codes should be 0999 and 09991" do
        if type_flag == 'T'
          container.payee_code_prefix.should == '0999'
          container.payee_code_suffix.should == '09991'
        end
      end
    end
  end

  # describe "lender paid mortgage insurance" do
  #   let(:container) { loan.escrow_disbursement_containers.find{|ed| ed.name == 'mortgage_insurance'} }

  #   before do
  #     loan.lender_paid_mi   = true
  #     loan.closing_on       = Date.new(2012, 3, 5)
  #     loan.mi_company_id    = 3124
  #     loan.base_loan_amount = 100000
  #   end

  #   it "should create mortgage_insurance card" do
  #     container.count.should == '01'
  #     container.type.should == '5'
  #     container.amount.should == 0

  #     container.date.to_date.should == (loan.closing_on + 12.months).to_date
  #     container.months.should == [ loan.closing_on.month, 0, 0, 0]

  #     container.type_qualifier.should == '1'
  #     container.certificate_identifier.should == '999999993'
  #     container.expiration_date.to_date.should == (loan.closing_on + 12.months).to_date

  #     container.payee_code_prefix.should == '0217'
  #     container.payee_code_suffix.should == '00000'

  #     container.coverage_amount.should == 100000
  #     container.coverage_code.should == 'N'
  #   end
  # end

  describe "mortgage insurance fields" do
    let(:container) { loan.escrow_disbursement_containers.find{|ed| ed.name == 'mortgage_insurance'} }

    before do
      allow_any_instance_of(Servicing::DisbursementInfoBuilderBase).to receive(:should_build?).and_return(true)
      add_escrow(loan, {item_type: 'MortgageInsurance'})
      loan.proposed_housing_expenses <<
        Master::ProposedHousingExpense.new(payment_amount: 123.76, housing_expense_type: 'slfkjfd') <<
        Master::ProposedHousingExpense.new(payment_amount: 456.11, housing_expense_type: 'MI' )
    end

    describe "certificate_identifier" do
      context "when it is an FHA loan" do
        before do 
          loan.mortgage_type = 'FHA' 
          loan.fha_case_identifier = 'abcde123'
          loan.agency_case_identifier = 'abc-123-xyz-9'
        end
        it "should use the agency case identifier, sanitized and prefixed with FR" do
          container.certificate_identifier.should == 'FRabc123xyz'
        end
      end
      context "when it is a FarmersHomeAdministration loan" do
        before do 
          loan.mortgage_type = 'FarmersHomeAdministration' 
          loan.agency_case_identifier = '354565465'
        end
        it "should use the agency case identifier and NO sanition or prefixes" do
          container.certificate_identifier.should == '354565465'
        end
      end
      context "when it is not an FHA loan" do
        before { loan.mortgage_type = 'Conventional' }
        it "should use the mi_certificate_id" do
          loan.mi_certificate_id = '8989898989'
          container.certificate_identifier.should == '8989898989'
        end
        context "when mi_company_id = 1673" do
          it "should prepend mi_certificate_id with 2 leading zeros" do
            loan.mi_company_id = 1673
            loan.mi_certificate_id = '8989898989'
            container.certificate_identifier.should == '008989898989'
          end
        end
      end
    end

    it "should not have a container when the amounts are missing" do
      loan.proposed_housing_expenses.clear
      loan.hud_lines.clear
      container.should be_nil
    end

    it "should not have a container when the mi amount is 0" do
      loan.proposed_housing_expenses.clear
      loan.hud_lines << build_hudline(line_num: 1003, system_fee_name: 'Mortgage insurance', 
                                            hud_type: 'HUD', monthly_amount: 0)
      loan.hud_lines.first.monthly_amount = 0
      container.should be_nil
    end

    describe "mortgage_insurance_payment_amount" do
      it "should use hud line 1003 if there is such a value" do
        loan.hud_lines.clear
        loan.hud_lines << build_hudline(line_num: 1003, system_fee_name: 'Mortgage insurance',
                                              hud_type: 'GFE', monthly_amount: 123.56)
        loan.hud_lines << build_hudline(line_num: 1003, system_fee_name: 'Mortgage insurance',
                                              hud_type: 'HUD', monthly_amount: 99.56)
        
        container.amount.should == 99.56
      end

      it "should be the MI monthly expense when there is no hud line 1003" do
        allow_any_instance_of(Servicing::DisbursementInfoBuilderBase).to receive(:net_fee_indicator).and_return(true)
        loan.hud_lines.clear
        container.amount.should == 456.11
      end
    end

    describe "mortgage_insurance_disbursement_type" do
      context "when escrow is collected" do
        before { 
          loan.escrow_waiver_indicator = false 
          allow_any_instance_of(Servicing::DisbursementInfoBuilderBase).to receive(:net_fee_indicator).and_return(true)
        }

        it "should be P for conventional mortgages" do
          loan.mortgage_type = 'Conventional'
          container.type.should == 'P'
        end

        it "should be R for FHA mortgages" do
          loan.mortgage_type = 'FHA'
          container.type.should == 'R'
        end

        it "should be P otherwise" do
          ['', nil, 'sdlfjsdf'].each do |value|
            loan.mortgage_type = value
            container.type.should == 'P'
          end
        end
      end
      
      context "when escrow is waived " do
        before { 
          loan.escrow_waiver_indicator = true 
          allow_any_instance_of(Servicing::DisbursementInfoBuilderBase).to receive(:net_fee_indicator).and_return(true)
        }

        it "for PMI should be P" do
          loan.mortgage_type = 'Conventional'
          container.type.should == 'P'
        end
        it "for FHA should be R" do
          loan.mortgage_type = 'FHA'
          container.type.should == 'R'
        end
      end

    end


    describe "mortgage_insurance_payment_date" do
      it "should be the latest scheduled payment date for mi escrow payments" do
        loan.escrows.clear
        loan.mortgage_type = 'Conventional'
        loan.escrows << fake_pmt(Date.new(2012, 3, 5), 'MortgageInsurance') \
          << fake_pmt(Date.new(2012, 3, 7), 'HomeInsurance') \
          << fake_pmt(Date.new(2012, 3, 1), 'MortgageInsurance')

        container.date.to_date.should == Date.new(2012, 3, 5) - 1.month
      end

      it "should be the latest scheduled payment date for mi escrow payments" do
        loan.escrows.clear
        loan.mortgage_type = 'FHA'
        loan.escrows << fake_pmt(Date.new(2012, 4, 5), 'MortgageInsurance') \
          << fake_pmt(Date.new(2012, 3, 7), 'HomeInsurance') \
          << fake_pmt(Date.new(2012, 3, 1), 'MortgageInsurance')

        container.date.to_date.should == Date.new(2012, 4, 5)
      end

      it "should be the latest scheduled payment date for mi escrow payments" do
        loan.mortgage_type = 'FarmersHomeAdministration'
        loan.escrows << fake_pmt(Date.new(2012, 3, 5), 'MortgageInsurance') \
          << fake_pmt(Date.new(2012, 3, 7), 'HomeInsurance') \
          << fake_pmt(Date.new(2012, 3, 1), 'MortgageInsurance')
        loan.closing_on = Date.new(2012, 3, 6)

        container.date.to_date.should == Date.new(2012, 3, 6) + 12.months
      end

      it "should be nil when there are no MI payments" do
        loan.escrows.clear
        loan.escrows << fake_pmt(Date.new(2012, 3, 5), 'HomeInsurance') \
          << fake_pmt(Date.new(2012, 3, 7), 'HomeInsurance')

        container.date.should == nil
      end

      def fake_pmt(date, type)
        foo = build_escrow due_date: date
        foo.stub item_type: type
        foo
      end
    end

    describe "mortgage insurance expiration date" do
      context "for FHA" do
        before { loan.mortgage_type = "FHA" }

        it "should be 11 months after the first payment date" do
          loan.first_payment_on = Date.new(2013, 3, 21)
          container.expiration_date.should == Date.new(2014, 2, 21)
        end
      end

      context "for conventional loans" do
        before { loan.mortgage_type = "Conventional" }

        it "expiration_date should be the scheduled termination date" do
          loan.mi_scheduled_termination_date = Date.new(2013, 3, 21)
          container.expiration_date.should == loan.mi_scheduled_termination_date
        end
      end
    end

    describe "mortgage insurance coverage amount" do
      before do 
        loan.base_loan_amount = 123456 
        loan.original_balance = 223456 
      end
      context "for FHA" do
        before { loan.mortgage_type = "FHA" }
        it "should be the full total loan amount" do
          container.coverage_amount.should == 223456
        end
      end

      context "for conventional loans" do
        before { loan.mortgage_type = "Conventional" }

        it "should be ignored when the coverage percent is missing" do
          loan.mi_coverage_percent = nil
          container.coverage_amount.should == loan.base_loan_amount
        end

        it "should not multiply when the coverage percent is present" do
          loan.mi_coverage_percent = 80
          container.coverage_amount.should == loan.base_loan_amount
        end
      end

      context "for other kinds of loans" do
        before { loan.mortgage_type = "slkfjdskljf" }

        it "should be 0 when coverage percent is missing" do
          loan.mi_coverage_percent = nil
          container.coverage_amount.should == 0
        end

        it "should be 0 when coverage percent is present" do
          loan.mi_coverage_percent = 80
          container.coverage_amount.should == 0
        end

      end
    end

    describe "disbursement type qualifier" do
      context "when the loan is USDA" do 
        before { loan.mortgage_type = "FarmersHomeAdministration" }
        it { container.type_qualifier.should == '8' }
      end
      context "when the loan is FHA" do 
        before { loan.mortgage_type = "FHA" }
        it { container.type_qualifier.should == ' ' }
      end
      context "For other loan types" do
        it { container.type_qualifier.should == '0' }
      end
    end

    describe "payee code" do
      context "when the loan is FHA" do 
        before { loan.mortgage_type = "FHA" }
        it "should use the FHA payee codes" do
          container.payee_code_prefix.should == '0213'
          container.payee_code_suffix.should == '56000'
        end
      end
      context "when the loan is FarmersHomeAdministration" do 
        before { loan.mortgage_type = "FarmersHomeAdministration" }
        it "should use the FHA payee codes" do
          container.payee_code_prefix.should == '0248'
          container.payee_code_suffix.should == '00000'
          container.coverage_code.should == 'N'
        end
      end
      context "when the loan is VA" do 
        before { loan.mortgage_type = "VA" }
        it "should use the dummy payee codes" do
          container.payee_code_prefix.should == '9999'
          container.payee_code_suffix.should == '99901'
        end
      end
      context "for conventional loans" do
        before { loan.mortgage_type = "Conventional" }

        { 3124  => '0217',
          1671  => '0219',
          1673  => '0200',
          1672  => '0210',
          1674  => '0215',
          8352  => '0220',
        }.each do |company_id, prefix|
          it "should use #{prefix} and 00000 when insured by #{company_id}" do
            loan.mi_company_id = company_id
            container.payee_code_prefix.should == prefix
            container.payee_code_suffix.should == '00000'
          end
        end
        it "should use the general payee code" do
          container.payee_code_prefix.should == '9999'
          container.payee_code_suffix.should == '99901'
        end
      end
    end

    let(:disbursement_type) { 'MortgageInsurance' }

    #it_behaves_like "disbursement count"
    #it_behaves_like "next payment months"

  end

  describe "mortgage insurance fields" do
    let(:container) { loan.escrow_disbursement_containers.find{|ed| ed.name == 'mortgage_insurance'} }

    it "coverage_code should == ' ' if payment frequency type not monthly" do
      loan.mortgage_type ='Conventional'
      add_escrow(loan, {item_type: 'MortgageInsurance', payment_frequency_type: 'Quarterly'})

      container.coverage_code.should == ' '
    end

    it "coverage_code should == 'N' if payment frequency type is monthly" do
      loan.mortgage_type ='Conventional'
      add_escrow(loan, {item_type: 'MortgageInsurance', payment_frequency_type: 'Monthly'})

      container.coverage_code.should == 'N'
    end
  end

  [ ['flood_insurance', 'FloodInsurance', 2, 'H', '999999993' ],
    ['annual_assessments', 'Assessment', 3, 'T', '999999991'],
    ['county_property_tax', 'CountyPropertyTax', 0, 'T', '999999991'],
    ['city_property_tax', 'CityPropertyTax', 1, 'T', '999999991'],
    ['hazard_insurance', 'HazardInsurance', 0, 'H', '999999993'],
  ].each do |pname, ptype, type_qualifier, ptype_flag, fake_cert_id|
    describe "#{pname} fields" do
      before { 
        loan.escrow_disbursement_types << build_escrow_disbursement_type(disbursement_type: disbursement_type) 
        allow_any_instance_of(Servicing::DisbursementInfoBuilderBase).to receive(:net_fee_indicator).and_return(true)
      }
      let(:name) { pname }
      let(:disbursement_type) { ptype }
      let(:type_flag) { ptype_flag }

      it "should not have a container when there is no disbursement of this type" do
        container.should be_nil
      end

      it "disbursement type qualifier" do
        add_escrow(loan, {item_type: disbursement_type})
        container.type_qualifier.to_s.should == type_qualifier.to_s
      end

      it "disbursement type flag" do
        add_escrow(loan, {item_type: disbursement_type})
        container.type.should == type_flag
      end

      # I have real tests for this now for hazard and flood insurance, but do not yet know what
      # to do for taxes.  Leaving this as a reminder 
      xit "fake cert id" do
        loan.escrow_disbursement_types << build_escrow_disbursement_type(disbursement_type: disbursement_type)
        container.certificate_identifier.should == fake_cert_id
      end

      it_behaves_like "disbursement count"
      it_behaves_like "payment amount" 
      it_behaves_like "payment date"
      it_behaves_like "next payment months"
      it_behaves_like "expiration date"
      it_behaves_like "payee code"
      it_behaves_like "disbursment type for non-escrowed lines"
    end
  end

  describe "certificate_identifier" do
    context "hazard insurance" do
      let(:name) { 'hazard_insurance' }
      before do 
        add_escrow(loan, {item_type: 'HazardInsurance'})
        loan.escrow_disbursement_types << build_escrow_disbursement_type(disbursement_type: 'HazardInsurance')
      end

      it "hazard insurance certificate should be from the policy number" do
        loan.hazard_insurance_policy_number = 'ZZZ1234'
        container.certificate_identifier.should == 'ZZZ1234'
      end
    end

    context "flood insurance" do
      let(:name) { 'flood_insurance' }
      before do 
        add_escrow(loan, {item_type: 'FloodInsurance'})
        loan.escrow_disbursement_types << build_escrow_disbursement_type(disbursement_type: 'FloodInsurance')
      end

      it "flood insurance certificate should be from the policy number" do
        loan.flood_insurance_policy_number = 'ZZZ1234'
        container.certificate_identifier.should == 'ZZZ1234'
      end
    end
  end

  [ ['wind',    'H', 3, '999999993'],
    ['village', 'T', 2, '999999991'],
    ['sewer',   'T', 3, '999999991'],
    ['school',  'T', 4, '999999991'],
    # ['another', 'E', 2, '999999991'],
  ].each do |pname, ptype_flag, type_qualifier, fake_cert_id|
    describe "#{pname} disbursements" do
      let(:name) { pname }
      let(:disbursement_type) { 'Other' }
      let(:type_flag) { ptype_flag }
      before do
        loan.escrow_disbursement_types << build_escrow_disbursement_type(disbursement_type: disbursement_type)
        loan.hud_lines << build_hudline(line_num: 1008, user_defined_fee_name: "foo #{name} bar", hud_type: 'HUD', monthly_amount: 1, num_months: 12)
        allow_any_instance_of(Servicing::DisbursementInfoBuilderBase).to receive(:net_fee_indicator).and_return(true)
      end

      it "type flag" do
        loan.escrows << build_escrow(item_type: disbursement_type, collected_number_of_months_count: 12)
        container.type.should == type_flag
      end

      it "type qualifier" do
        loan.escrows << build_escrow(item_type: disbursement_type, collected_number_of_months_count: 12)
        container.type_qualifier.to_s.should == type_qualifier.to_s
      end

      it "fake cert id" do
        loan.escrows << build_escrow(item_type: disbursement_type, collected_number_of_months_count: 12)
        container.certificate_identifier.to_s.should == fake_cert_id.to_s
      end

      others = [ 'wind', 'village', 'sewer', 'school', 'some other thing', ] - [pname]
      others.each do |other_name|
        it "should not have a container for #{other_name} disbursement" do
          loan.escrow_disbursement_types.clear
          loan.escrow_disbursement_types << build_escrow_disbursement_type(disbursement_type: disbursement_type)
          loan.escrow_disbursement_containers.find{|ed| ed.name == other_name }.should be_nil
        end
      end

      it_behaves_like "disbursement count"
      it_behaves_like "payment amount"
      it_behaves_like "payment date"
      it_behaves_like "next payment months"
      it_behaves_like "expiration date"
      it_behaves_like "payee code"
      it_behaves_like "disbursment type for non-escrowed lines"
    end
  end

  describe "escrow_first_payment_date" do
    before { loan.stub first_payment_on: Date.new(2012, 1, 2) }

    context "when there are no previous payments" do
      it "should be the first payment date" do
        loan.payment_occurrences.should be_empty
        loan.escrow_first_payment_date.should == Date.new(2012, 1, 2)
      end
    end

    context "when there are previous payments" do
      before do
        loan.payment_occurrences << Master::PaymentOccurrence.new({payment_received_on: Date.new(2013, 1, 1)}, without_protection: true)
        loan.payment_occurrences << Master::PaymentOccurrence.new({payment_received_on: Date.new(2013, 2, 1)}, without_protection: true)
        loan.payment_occurrences << Master::PaymentOccurrence.new
      end

      it "should be the first payment date plus one month per prev pmt where the date is not null" do
        loan.escrow_first_payment_date.should == Date.new(2012, 3, 2)
      end
    end
  end

  describe "primary_borrower_total_monthly_income" do
    it "should be the sum of all the primary borrower's income sources" do
      primary_borrower.income_sources << Master::IncomeSource.new(monthly_amount: 100.01)
      primary_borrower.income_sources << Master::IncomeSource.new(monthly_amount: 200.02)
      secondary_borrower.income_sources << Master::IncomeSource.new(monthly_amount: 300.03)
      loan.primary_borrower_total_monthly_income.should == 100.01 + 200.02
    end
  end

  describe "primary borrower income fields" do
    it "primary_borrower_income_of_type" do
      add_income_source primary_borrower, monthly_amount: 100.01, income_type: 'Base'
      add_income_source primary_borrower, monthly_amount: 100.02, income_type: 'Base'
      add_income_source primary_borrower, monthly_amount: 200.02, income_type: 'Rental'
      add_income_source secondary_borrower, monthly_amount: 300.03, income_type: 'Base'
      
      loan.primary_borrower_income_of_type("Base").should == 100.01 + 100.02
    end

    it "primary_borrower_income_other" do
      add_income_source primary_borrower, monthly_amount: 100.01, income_type: 'Foo'
      add_income_source primary_borrower, monthly_amount: 100.02, income_type: 'Bar'
      add_income_source primary_borrower, monthly_amount: 200.02, income_type: 'Commission'
      add_income_source primary_borrower, monthly_amount: 200.02, income_type: 'Base'
      add_income_source primary_borrower, monthly_amount: 200.02, income_type: 'NetRentalIncome'
      
      loan.primary_borrower_income_other.should == 100.01 + 100.02
    end

    it "primary borrower total income" do
      add_income_source primary_borrower, monthly_amount: 100.01, income_type: 'Foo'
      add_income_source primary_borrower, monthly_amount: 100.02, income_type: 'Bar'
      add_income_source primary_borrower, monthly_amount: 200.02, income_type: 'Commission'
      
      loan.primary_borrower_total_monthly_income.should == 100.01 + 100.02 + 200.02
    end
  end

  describe "secondary borrower income fields" do
    it "secondary_borrower_income_of_type" do
      add_income_source secondary_borrower, monthly_amount: 100.01, income_type: 'Base'
      add_income_source secondary_borrower, monthly_amount: 100.02, income_type: 'Base'
      add_income_source secondary_borrower, monthly_amount: 200.02, income_type: 'Rental'
      add_income_source primary_borrower, monthly_amount: 300.03, income_type: 'Base'
      
      loan.secondary_borrower_income_of_type("Base").should == 100.01 + 100.02
    end

    it "secondary_borrower_income_other" do
      add_income_source secondary_borrower, monthly_amount: 100.01, income_type: 'Foo'
      add_income_source secondary_borrower, monthly_amount: 100.02, income_type: 'Bar'
      add_income_source secondary_borrower, monthly_amount: 200.02, income_type: 'Commission'
      add_income_source secondary_borrower, monthly_amount: 200.02, income_type: 'Base'
      add_income_source secondary_borrower, monthly_amount: 200.02, income_type: 'NetRentalIncome'
      
      loan.secondary_borrower_income_other.should == 100.01 + 100.02
    end

    it "secondary borrower total income" do
      add_income_source secondary_borrower, monthly_amount: 100.01, income_type: 'Foo'
      add_income_source secondary_borrower, monthly_amount: 100.02, income_type: 'Bar'
      add_income_source secondary_borrower, monthly_amount: 200.02, income_type: 'Commission'
      
      loan.secondary_borrower_total_monthly_income.should == 100.01 + 100.02 + 200.02
    end
  end

  it "total_liability_amount" do
    loan.liabilities << Master::Liability.new(unpaid_balance_amount: 10_000.01)
    loan.liabilities << Master::Liability.new(unpaid_balance_amount: 20_000.02)

    loan.total_liability_amount.should == 30_000.03
  end

  it "total_assets_value" do
    loan.assets << Master::Asset.new(asset_type: 'CheckingAccount', amount: 10_000.01)
    loan.assets << Master::Asset.new(asset_type: 'Stock', amount: 20_000.02)

    loan.total_assets_value.should == 30_000.03
  end

  it "total_stock_value" do
    loan.assets << Master::Asset.new(asset_type: 'CheckingAccount', amount: 10_000.01)
    loan.assets << Master::Asset.new(asset_type: 'Stock', amount: 20_000.02)
    loan.assets << Master::Asset.new(asset_type: 'Stock', amount: 30_000.03)

    loan.total_stock_value.should == 50_000.05
  end

  describe "is_employee_loan?" do
    [ '1', 1 ].each do |val|
      it "should be true for #{val}" do
        loan.employee_loan_indicator = val
        loan.is_employee_loan?.should be true
      end
    end

    [ '0', 0, nil].each do |val|
      it "should be false for #{val}" do
        loan.employee_loan_indicator = val
        loan.is_employee_loan?.should be_falsey
      end
    end
  end

  describe "has_subordinate_financing?" do
    let(:underlying_loan) { Loan.new }
    before do 
      loan.loan_num = 1234
      Loan.stub(:find_by_loan_num).with(1234).and_return(underlying_loan)
    end
    context "when there is sub fin" do
      before { underlying_loan.stub(:subordinate_financing?).and_return("Yes") }
      it { loan.has_subordinate_financing?.should be true }
    end
    context "when there is no sub fin" do
      before { underlying_loan.stub(:subordinate_financing?).and_return("No") }
      it { loan.has_subordinate_financing?.should be false }
    end
  end

  describe "escrow_pays_interest?" do
    it "should be true when the property is in certain states" do
      Servicing::FiservDataSource::STATES_PAYING_INTEREST_ON_ESCROW.each do |state|
        loan.property_state = state
        loan.escrow_pays_interest?.should be true
      end
    end

    it "should be false otherwise" do
      loan.property_state = "MI"
      loan.escrow_pays_interest?.should == false
    end

  end

  def add_income_source(borrower, opts={})
    borrower.income_sources << Master::IncomeSource.new(opts)
  end

  def build_fake_borrower opts
    b = Master::Person::Borrower.new opts
    b.stub employer: Master::Employer.new
    b.stub residence: Master::Residence.new
    b.stub income_sources: []
    b
  end

  def build_hudline(opts={})
    Master::HudLine.new opts, without_protection: true
  end

  def build_escrow(opts={})
    Master::Escrow.new opts, without_protection: true
  end

  def build_escrow_disbursement_type(opts={})
    Master::EscrowDisbursementType.new opts, without_protection: true
  end

  def build_escrow_disbursement(opts={})
    Master::EscrowDisbursement.new opts, without_protection: true
  end

  def add_escrow(loan, escrow_options = {}, hud_line_options = {})
    item_type         = escrow_options[:item_type]
    payment_frequency = escrow_options[:payment_frequency_type]
    hud_line_number    = Array(Master::HudLine::LINE_NUMBER_LOOKUP[item_type.underscore.to_sym]).first

    user_defined_fee_name = hud_line_options[:user_defined_fee_name]

    loan.hud_lines << build_hudline(line_num: hud_line_number,
                                    hud_type: 'HUD', 
                                    monthly_amount: 1,
                                    num_months: 12,
                                    user_defined_fee_name: user_defined_fee_name)

    loan.escrows << build_escrow(item_type: item_type, 
                                 collected_number_of_months_count: 12, 
                                 payment_frequency_type: payment_frequency)

    loan
  end

end
