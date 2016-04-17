require 'spec_helper'

describe BuildDataCompare do
  let(:loan) { Loan.new }
  let(:result) { BuildDataCompare.call loan }

  before do
    loan.stub lock_loan_datum: build_stubbed(:lock_loan_datum)
    loan.stub ltv: nil
  end

  it "should return a DataCompare" do
    expect(result).to be_a BuildDataCompare::DataCompare
  end

  it "it should not break if the loan has not been locked" do
    loan.stub lock_loan_datum: nil
    expect{result}.not_to raise_error
  end

  describe "amortization" do
    it "lock_value should come from LLD amortization" do
      loan.stub_chain(:lock_loan_datum, :loan_amortization_term_months).and_return 123
      expect(lock_value("Amortization")).to eq 123
    end

    it "1003 value should come from MortgageTerms" do
      loan.stub_chain(:mortgage_term, :loan_amortization_term_months).and_return 444
      expect(form_1003_value("Amortization")).to eq 444
    end
  end

  describe "Applicants" do
    it "lock_value should come from the LLD borrower fields" do
      loan.lock_loan_datum.borrower_first_name = "Fred"
      loan.lock_loan_datum.borrower_last_name = "Flintstone"
      loan.lock_loan_datum.coborrower_first_name = "Barney"
      loan.lock_loan_datum.coborrower_last_name = "Rubble"
      expect(lock_value("Applicants")).to eq "Fred Flintstone, Barney Rubble"
    end

    it "form_1003_value should come from first four borrowers" do
      loan.stub borrowers: [
        make_borrower(borrower_id: "BRW1", first_name: "Alice", last_name: "A"),
        make_borrower(borrower_id: "BRW2", first_name: "Bob", last_name: "B"),
        make_borrower(borrower_id: "BRW3", first_name: "Chuck", last_name: "C"),
        make_borrower(borrower_id: "BRW4", first_name: "Dave", last_name: "D"),
        make_borrower(borrower_id: "BRW5", first_name: "Ed", last_name: "E"),
      ]
      expect(form_1003_value("Applicants")).to eq "Alice A, Bob B, Chuck C, Dave D"
    end
  end

  describe "ARM Index" do
    it "lock value should be n/a" do
      expect(lock_value("ARM Index")).to eq :not_applicable
    end

    it "form_1003_value should come from arm table" do
      loan.stub_chain(:arm, :index_current_value_percent).and_return 0.123
      expect(form_1003_value("ARM Index")).to eq 0.123
    end
  end

  describe "Base Loan Amount" do
    it "lock value should be n/a" do
      expect(lock_value("Base Loan Amount")).to eq :not_applicable
    end

    it "form_1003_value should come from arm table" do
      loan.stub_chain(:mortgage_term, :base_loan_amount).and_return 12345
      expect(form_1003_value("Base Loan Amount")).to eq 12345
    end
  end

  describe "Box A Discount" do
    it "lock value should be nothing if lock price is over 100" do
      loan.stub_chain(:lock_price, :net_price).and_return(101.2344)
      expect(lock_value("Box A Discount")).to eq ""
    end

    it "lock value should subtract it from 100 if it is less than 100 " do
      loan.stub_chain(:lock_price, :net_price).and_return(98.2344)
      expect(lock_value("Box A Discount")).to eq "1.766"
    end

    it "form_1003_value should be n/a" do
      expect(form_1003_value("Box A Discount")).to eq :not_applicable
    end
  end

  describe "Escrow Waiver" do
    it "lock value should be yes if lld escrow waiver indicator" do
      loan.lock_loan_datum.escrow_waiver_indicator = true
      expect(lock_value("Escrow Waiver")).to eq "Yes"
    end

    it "lock value should be no unless lld escrow waiver indicator" do
      loan.lock_loan_datum.escrow_waiver_indicator = false
      expect(lock_value("Escrow Waiver")).to eq "No"
    end

    it "form_1003_value should be yes if loan_feature escrow waiver indicator" do
      loan.stub_chain(:loan_feature, :escrow_waiver_indicator).and_return(true)
      expect(form_1003_value("Escrow Waiver")).to eq "Yes"
    end

    it "form_1003_value should be no unless loan_feature escrow waiver indicator" do
      loan.stub_chain(:loan_feature, :escrow_waiver_indicator).and_return(false)
      expect(form_1003_value("Escrow Waiver")).to eq "No"
    end
  end

  describe "Estimated Property Value" do
    it "lock value should be from lld property_appraised_value_amount" do
      loan.lock_loan_datum.property_appraised_value_amount = 100_000
      expect(lock_value("Estimated Property Value")).to eq 100_000
    end

    it "form_1003_value should equal estimated transmittal value if present" do
      loan.stub_chain(:transmittal_datum, :property_estimated_value_amount).and_return(1234)
      loan.stub_chain(:transmittal_datum, :property_appraised_value_amount).and_return(2234)
      expect(form_1003_value("Estimated Property Value")).to eq BuildDataCompare::ValueWithDisplay.new(1234, 'bar')
      expect(form_1003_value("Estimated Property Value").as_json).to eq "Estimated 1234"
    end

    it "form_1003_value should equal appraised transmittal value if no est is present" do
      loan.stub_chain(:transmittal_datum, :property_estimated_value_amount).and_return(nil)
      loan.stub_chain(:transmittal_datum, :property_appraised_value_amount).and_return(2234)
      expect(form_1003_value("Estimated Property Value")).to eq BuildDataCompare::ValueWithDisplay.new(2234, 'foo')
      expect(form_1003_value("Estimated Property Value").as_json).to eq "Actual 2234"
    end
  end

  describe "FHA MIP" do
    it "lock value should be not_applicable" do
      expect(lock_value("FHA MIP")).to eq :not_applicable
    end

    it "form_1003_value should come from fha_loan" do
      loan.stub_chain(:fha_loan, :upfront_mi_premium_percent).and_return(123)
      expect(form_1003_value("FHA MIP")).to eq 123
    end
  end

  describe "Interest Rate" do
    it "lock value should come from lock_price" do
      loan.stub_chain(:lock_price, :final_note_rate).and_return 92
      expect(lock_value("Interest Rate")).to eq 92
    end

    it "form_1003_value should come from mortgage_term" do
      loan.stub_chain(:mortgage_term, :requested_interest_rate_percent).and_return 4.35
      expect(form_1003_value("Interest Rate")).to eq 4.35
    end
  end

  describe "Lender NMLS" do
    it "lock value should be n/a" do
      expect(lock_value("Lender NMLS")).to eq :not_applicable
    end

    it "form_1003_value should come from interviewer" do
      loan.stub_chain(:interviewer, :individual_nmls_id).and_return 12345
      expect(form_1003_value("Lender NMLS")).to eq 12345
    end
  end

  describe "Loan Product" do

    it "lock value should come from lock price" do
      loan.stub_chain(:lock_price, :product_code).and_return "C30FXD"
      expect(lock_value("Loan Product")).to eq "C30FXD"
    end

    it "should pull form_1003_value from underwriting data as default" do
      gfe_datum = double
      add_loan_datum = double
      uw_datum = double
      loan.stub loan_general: build_stubbed(:loan_general)
      loan.stub_chain(:loan_general, :gfe_loan_datum).and_return gfe_datum
      loan.stub_chain(:loan_general, :additional_loan_datum).and_return add_loan_datum
      loan.stub_chain(:loan_general, :underwriting_datum).and_return uw_datum
      allow(gfe_datum).to receive(:loan_program).and_return("C15FXD") 
      allow(uw_datum).to receive(:product_code).and_return "FHA15FXD"
      allow(add_loan_datum).to receive(:pipeline_loan_status_description).and_return("U/W Denied")  

      expect(form_1003_value("Loan Product")).to eq "FHA15FXD"
    end

    ["New","File Received","U/W Received","U/W Submitted"].each do |status|
      it "should pull form_1003_value from GFE loan when status is #{status}" do
        loan.stub loan_general: build_stubbed(:loan_general)
        gfe_datum = double
        add_loan_datum = double
        uw_datum = double
        loan.stub_chain(:loan_general, :gfe_loan_datum).and_return gfe_datum
        loan.stub_chain(:loan_general, :additional_loan_datum).and_return add_loan_datum
        loan.stub_chain(:loan_general, :underwriting_datum).and_return uw_datum
        allow(gfe_datum).to receive(:loan_program).and_return("C15FXD")
        allow(uw_datum).to receive(:product_code).and_return("C5/1ARM LIB")
        allow(add_loan_datum).to receive(:pipeline_loan_status_description).and_return(status)

        expect(form_1003_value("Loan Product")).to eq "C15FXD"
      end
    end

  end

  describe "Loan Purpose Type" do
    it "lock_value should come from lld" do
      loan.lock_loan_datum.loan_purpose_type = "Refinance"
      expect(lock_value("Loan Purpose Type")).to eq "Refinance"
    end

    it "form_1003_value should come from loanpurpose" do
      loan.stub_chain(:loan_purpose, :loan_type).and_return "Purchase"
      expect(form_1003_value("Loan Purpose Type")).to eq "Purchase"
    end
  end

  describe "Loan Term" do
    it "lock_value should come from lld LoanMaturityTermMonths" do
      loan.lock_loan_datum.maturity_term_months = 123
      expect(lock_value("Loan Term")).to eq 123
    end

    it "form_1003_value should come from mortgage_term" do
      loan.stub_chain(:mortgage_term, :loan_amortization_term_months).and_return 300
      expect(form_1003_value("Loan Term")).to eq 300
    end
  end

  describe "Loan Type" do
    describe "lock_value should come from the product code translation" do
      [ "C10/1ARM LIB HIBAL", "C10/1ARM LIB RP", "C10/1ARM LIBOR", "C15FXD", "C15FXD FR",
        "C15FXD HIBAL", "C15FXD RP", "C15FXD RP CD", "C20FXD", "C20FXD FR", "C20FXD HIBAL",
        "C20FXD RP", "C30FXD", "C30FXD FR", "C30FXD HIBAL", "C30FXD HP", "C30FXD MCM", "C30FXD RP",
        "C30FXD RP CD", "C30FXD TEST", "C5/1ARM LIB HIBAL", "C5/1ARM LIB RP", "C5/1ARM LIB",
        "C7/1ARM LIB HIBAL", "C7/1ARM LIB RP", "C7/1ARM LIB", "J15FXD", "J30FXD", "J5/1ARM LIB",
        "J7/1ARM LIB", "J10/1ARM LIB", "TEST J15FXD", "TEST J30FXD",
      ].each do |code|
        it "#{code} should be conventional" do
          loan.stub_chain(:lock_price, :product_code).and_return(code)
          expect(lock_value("Loan Type")).to eq "Conventional"
        end
      end

      [ "FHA30 IHCDA IN NH", "FHA30 IHDA IL SM", "FHA30STR", "FHA15FXD", "FHA30FXD",
      ].each do |code|
        it "#{code} should be FHA" do
          loan.stub_chain(:lock_price, :product_code).and_return(code)
          expect(lock_value("Loan Type")).to eq "FHA"
        end
      end

      it "USDA30FXD should be USDA" do
        loan.stub_chain(:lock_price, :product_code).and_return("USDA30FXD")
        expect(lock_value("Loan Type")).to eq "USDA"
      end

      [ "VA15FXD", "VA30FXD", "VA30IRRL",
      ].each do |code|
        it "#{code} should be VA" do
          loan.stub_chain(:lock_price, :product_code).and_return(code)
          expect(lock_value("Loan Type")).to eq "VA"
        end
      end
    end

    it "form_1003_value should just be from mortgage_term.mortgage_type?  IDK" do
      loan.stub_chain(:mortgage_term, :mortgage_type).and_return("foo")
      expect(form_1003_value("Loan Type")).to eq "foo"
    end


  end

  describe "LPMI" do
    it "lock_value should be yes if lld.lender_paid_mi" do
      loan.lock_loan_datum.lender_paid_mi = true
      expect(lock_value("LPMI")).to eq "Yes"
    end

    it "lock_value should be no unless lld.lender_paid_mi" do
      loan.lock_loan_datum.lender_paid_mi = false
      expect(lock_value("LPMI")).to eq "No"
    end

    it "form_1003_value should be yes if mi_program_1003 is 1" do
      loan.stub_chain(:mi_datum, :mi_program_1003).and_return(1)
      expect(form_1003_value("LPMI")).to eq "Yes"
    end

    [ nil, 2, 3, 4 ].each do |val|
      it "form_1003_value should be no if mi_program_1003 #{val}" do
        loan.stub_chain(:mi_datum, :mi_program_1003).and_return(val)
        expect(form_1003_value("LPMI")).to eq "No"
      end
    end
  end

  describe "LTV" do
    it "lock_value should come from lld" do
      loan.lock_loan_datum.ltv = '82'
      expect(lock_value("LTV")).to eq "82.000"
    end

    it "form_1003_value should be the ltv fact tyep calculation" do
      loan.stub ltv: 90
      expect(form_1003_value("LTV")).to eq "90.000"
    end
  end

  describe "MI" do
    it "lock_value should be yes when lld mi_indicator is true" do
      loan.lock_loan_datum.mi_indicator = true
      expect(lock_value("MI")).to eq "Yes"
    end

    it "lock_value should be no when lld mi_indicator is false" do
      loan.lock_loan_datum.mi_indicator = false
      expect(lock_value("MI")).to eq "No"
    end

    it "form_1003_value should be yes when mi_data has a value set" do
      [1,2,3,4].each do |value|
        loan.stub_chain(:mi_datum, :mi_program_1003).and_return(1)
        expect(form_1003_value("MI")).to eq "Yes"
      end
    end

    it "form_1003_value should be No when mi_data.mi_program_1003 ahs no value set" do
      loan.stub_chain(:mi_datum, :mi_program_1003).and_return(nil)
      expect(form_1003_value("MI")).to eq "No"
    end
  end

  describe "Premium Pricing Amount" do
    it "lock value should be blank if net_price is <= 100" do
      [99.1, 100.0].each do |value|
        loan.stub_chain(:lock_price, :net_price).and_return(value)
        expect(lock_value("Premium Pricing Amount")).to eq ""
      end
    end

    it "lock_value should be 100 - net_price if net_price > 100" do
      loan.stub_chain(:lock_price, :net_price).and_return(101.1234)
      expect(lock_value("Premium Pricing Amount")).to eq "-1.123"
    end

    it "form_1003_value should be n/a" do
      expect(form_1003_value("Premium Pricing Amount")).to eq :not_applicable
    end
  end

  describe "Property Address" do
    it "lock_value should come from lld" do
      loan.lock_loan_datum.property_street_address_number = 123
      loan.lock_loan_datum.property_street_address_name = "Bullshit Lane"
      loan.lock_loan_datum.property_street_address_unit = '1000'
      loan.lock_loan_datum.property_city = "Nowhere"
      loan.lock_loan_datum.property_state = "KA"
      loan.lock_loan_datum.property_postal_code = "66666"

      expect(lock_value("Property Address")).to eq "123 Bullshit Lane 1000 Nowhere KA 66666"
    end

    it "form_1003_value should come from property table" do
      loan.stub_chain(:property, :street_number).and_return(123)
      loan.stub_chain(:property, :street_name).and_return("Herpderp Plaza")
      loan.stub_chain(:property, :street_unit).and_return(666)
      loan.stub_chain(:property, :city).and_return("Elsewhere")
      loan.stub_chain(:property, :state).and_return("MO")
      loan.stub_chain(:property, :zip).and_return(99999)

      expect(form_1003_value("Property Address")).to eq "123 Herpderp Plaza 666 Elsewhere MO 99999"
    end
  end

  describe "Sales Price" do
    it "lock_value should come from lld purchase_price_amount" do
      allow(loan).to receive(:loan_type).and_return "Purchase"
      loan.lock_loan_datum.purchase_price_amount = 123_456
      expect(lock_value("Sales Price")).to eq 123_456
    end

    it "lock_value should be zero if Refinance" do
      allow(loan).to receive(:loan_type).and_return "Refinance"
      loan.lock_loan_datum.purchase_price_amount = 123_456
      expect(lock_value("Sales Price")).to eq 0
    end

    it "form_1003_value should come from TRANSACTION_DETAIL" do
      allow(loan).to receive(:loan_type).and_return "Purchase"
      loan.stub_chain(:transaction_detail, :purchase_price_amount).and_return(123)
      expect(form_1003_value("Sales Price")).to eq 123
    end

    it "form_1003_value should be zero if Refinance" do
      allow(loan).to receive(:loan_type).and_return "Refinance"
      loan.stub_chain(:transaction_detail, :purchase_price_amount).and_return(123)
      expect(form_1003_value("Sales Price")).to eq 0
    end
  end

  describe "Total Loan Amount" do
    it "lock_value should come from lld" do
      loan.lock_loan_datum.total_loan_amt = 123
      expect(lock_value("Total Loan Amount")).to eq 123
    end

    it "form_1003_value should come from mortgage_term" do
      loan.stub_chain(:mortgage_term, :borrower_requested_loan_amount).and_return(123)
      expect(form_1003_value("Total Loan Amount")).to eq 123
    end
  end

  describe "USDA Gfee" do
    it "lock_value should be n/a" do
      expect(lock_value("USDA Gfee")).to eq :not_applicable
    end

    it "form_1003_value should come from transaction_detail" do
      loan.stub_chain(:transaction_detail, :mi_and_funding_fee_total_amount).and_return("foo")
      expect(form_1003_value("USDA Gfee")).to eq "foo"
    end
  end

  describe "VA Funding Fee" do
    it "lock_value should be n/a" do
      expect(lock_value("VA Funding Fee")).to eq :not_applicable
    end

    it "form_1003_value should come from transaction_detail" do
      loan.stub_chain(:transaction_detail, :mi_and_funding_fee_financed_amount).and_return("foo")
      expect(form_1003_value("VA Funding Fee")).to eq "foo"
    end
  end

  describe BuildDataCompare::DataCompare do
    subject { BuildDataCompare::DataCompare.new loan }

    before do 
      AppendValidationWarningHistory.stub(:call) { |stuff| stuff }
    end

    it "should include errors in its as_json" do
      subject.stub errors: "foo"
      expect(subject.as_json).to include "errors" => "foo"
    end

    context "when locked" do
      before { loan.stub :is_locked? => true }

      it "should include conclusion: 'Pass' in the json" do
        expect(subject.as_json).to include "conclusion" => "Pass"
      end

      it "errors should not actually include errs from all fields that have non-nil errors" do
        subject.fields << BuildDataCompare::Field.new.tap {|f| f.stub error: "foo" }
        subject.fields << BuildDataCompare::Field.new.tap {|f| f.stub error: "bar" }
        subject.fields << BuildDataCompare::Field.new.tap {|f| f.stub error: nil }
        # expect(subject.errors.map{|e| e[:text]}).to eq [ "foo", "bar" ]
        expect(subject.errors).to eq []
      end

      # no point appending hisotry when we're not actually including errors
      xit "should attach history for all the errors" do
        AppendValidationWarningHistory.stub call: "stuff"
        expect(subject.errors).to eq "stuff"
      end
    end

    context "when not locked" do
      before { loan.stub :is_locked? => false }

      it "should not actually check for errors" do
        subject.fields << BuildDataCompare::Field.new.tap {|f| f.stub error: nil }
        expect(subject.errors).to eq []
      end

      it "should report conclusion: not locked in the json" do
        expect(subject.as_json).to include "conclusion" => "Not Locked"
      end
    end
  end


  describe "field" do
    let(:field) { BuildDataCompare::Field.new }

    context "when the values are the same" do
      before do
        field.lock_value = "foo"
        field.form_1003_value = "foo"
      end

      it "should match" do
        expect(field.match?).to be true
      end

      it "should have no error" do
        expect(field.error).to be nil
      end
    end

    context "when the values are different" do
      before do
        field.lock_value = "foo"
        field.form_1003_value = "bar"
      end

      it "should not match" do
        expect(field.match?).to be false
      end

      it "should report an error" do
        field.name = "Something"
        expect(field.error).to eq "Data Compare: Something was 'foo' at lock and 'bar' on the 1003"
      end
    end

    context "when the values are teh same but cases are different" do
      before do
        field.lock_value = "FoO"
        field.form_1003_value = "fOo"
      end

      it "should match" do
        expect(field.match?).to be true
      end
    end

    describe "not applicable" do
      it "on lock_value should match anything" do
        field.lock_value = :not_applicable
        field.form_1003_value = "foo"
        expect(field.match?).to be true
      end

      it "on form_1003_value should match anything" do
        field.lock_value = "foo"
        field.form_1003_value = :not_applicable
        expect(field.match?).to be true
      end

      it "should render as json reasonably" do
        field.lock_value = :not_applicable
        field.form_1003_value = :not_applicable
        expect(field.as_json).to include "lock_value" => "N/A", "form_1003_value" => "N/A"
      end
    end

    it "match should allow for lock_value being a ValueWithDisplay" do
      field.lock_value = BuildDataCompare::ValueWithDisplay.new "abc", "foo"
      field.form_1003_value = "abc"
      expect(field.match?).to be true
    end

    it "match should allow for form_1003_value being a ValueWithDisplay" do
      field.form_1003_value = BuildDataCompare::ValueWithDisplay.new "abc", "foo"
      field.lock_value = "abc"
      expect(field.match?).to be true
    end

    it "should include match in the json" do
      field.name = "something"
      field.lock_value = "foo"
      field.form_1003_value = "bar"
      expect(field.as_json).to eq({
        "name" => "something",
        "lock_value" => "foo", 
        "form_1003_value" => "bar",
        "match" => false
      })
    end
  end

  describe BuildDataCompare::ValueWithDisplay do

    describe "equality" do
      it "should compare by its value" do
        a = BuildDataCompare::ValueWithDisplay.new 123, "foo"
        b = BuildDataCompare::ValueWithDisplay.new 123, "bar"
        expect(a == b).to be true
        expect(b == a).to be true
      end

      it "should be false if the other thing is not the same class" do
        a = BuildDataCompare::ValueWithDisplay.new 123, "foo"
        expect(123 == a).to be false
      end
    end

    it "should only render its display for as_json" do
      x = BuildDataCompare::ValueWithDisplay.new 123, "sdlfj"
      expect(x.as_json).to eq "sdlfj"
    end

    it "should use its display value for to_s" do
      x = BuildDataCompare::ValueWithDisplay.new 123, "sdlfj"
      expect(x.to_s).to eq "sdlfj"
    end
  end

  def lock_value name
    find_field(name).lock_value
  end

  def form_1003_value name
    find_field(name).form_1003_value
  end

  def find_field name
    field = result.fields.find {|f| f.name == name }
    raise "could not find field with name #{name}" unless field
    field
  end

  def make_borrower opts
    Borrower.new opts, without_protection: true
  end
end
