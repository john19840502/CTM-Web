require 'spec_helper'

describe Loan do
  describe 'instance methods' do
    subject { build_stubbed :loan }
    smoke_test :appraised_value
    smoke_test :area_manager
    smoke_test :borrowers
    smoke_test :borrower_first_name
    smoke_test :borrower_last_name
    smoke_test :branch_name
    smoke_test :channel
    smoke_test :loan_amount
    smoke_test :loan_num
    smoke_test :loan_purpose
    smoke_test :loan_status
    smoke_test :ltv
    smoke_test :occupancy
    smoke_test :product_code
    smoke_test :property
    smoke_test :property_city
    smoke_test :property_street
    smoke_test :property_zip
    smoke_test :signed_1003_at
    smoke_test :last_status_date
    smoke_test :originator_name
    smoke_test :purpose
    smoke_test(:name)
    smoke_test(:lock_term)
    smoke_test(:amount)
    smoke_test(:program)
    smoke_test(:is_construction_only?)
    smoke_test(:is_construction_to_permanent?)
    smoke_test(:borrowers_income_total)
    smoke_test(:escrow_waiver?)
    smoke_test :fact_types
  end

  context "sqlserver views" do
    it { Loan::CREATE_VIEW_SQL.should_not be_empty }
    it { Loan.should respond_to(:sqlserver_create_view) }
    it { Loan.sqlserver_create_view.should_not be_empty }
  end

  context "#signature_dates_match?" do
    it "returns true when the signature dates match" do
      subject.stub_chain(:borrowers,:map).and_return ["010115","010115","010115"]
      expect(subject.signature_dates_match?).to eq(true)
    end

    it "returns false when the signature dates do not match" do
      subject.stub_chain(:borrowers,:map).and_return ["010415","010115","010115"]
      expect(subject.signature_dates_match?).to eq(false)
    end
  end

  it 'is_jumbo?' do
    subject.stub(:product_code).and_return('J')
    subject.is_jumbo?.should be true
  end

  it 'is_not_jumbo?' do
    subject.stub(:product_code).and_return('X')
    subject.is_jumbo?.should_not be true
  end

  describe "mshda_note_indicator_check" do
    it "should return No if content does not include Signed MSHDA seller affidavit received - signed prior to closing" do
      subject.stub(:loan_notes_notes) {[ build_stubbed(:loan_notes_note, content: 'Application returned & file to be submitted today'), build_stubbed(:loan_notes_note, content: 'New appl going out today. Loan lock extended.')]}
      expect(subject.mshda_note_indicator_check).to eq('No')
    end

    it "should return Yes if content does not include Signed MSHDA seller affidavit received - signed prior to closing" do
      subject.stub(:loan_notes_notes) {[ build_stubbed(:loan_notes_note, content: 'Signed MSHDA seller affidavit received - signed prior to closing'), build_stubbed(:loan_notes_note, content: 'New appl going out today. Loan lock extended.')]}
      expect(subject.mshda_note_indicator_check).to eq('Yes')
    end
  end

  describe "calculating closing plus rescission date" do
    it 'should move closing plus rescission date to monday if it falls on sunday' do
      subject.stub_chain(:loan_feature, :requested_closing_date).and_return(Time.new(2014,9,17))
      expect(subject.calculate_closing_plus_rescission_date.to_date).to eq(Date.new(2014,9,22))
    end

    it 'should move closing plus rescission date to next business day if it falls on a federal holiday' do
      subject.stub_chain(:loan_feature, :requested_closing_date).and_return(Time.new(2014,10,7))
      expect(subject.calculate_closing_plus_rescission_date.to_date).to eq(Date.new(2014,10,14))
    end

    it 'should include saturdays for calculating the closing plus rescission date' do
      subject.stub_chain(:loan_feature, :requested_closing_date).and_return(Time.new(2014,10,17))
      expect(subject.calculate_closing_plus_rescission_date.to_date).to eq(Date.new(2014,10,22))
    end

    it 'should not consider even if the closing date is a holiday' do
      subject.stub_chain(:loan_feature, :requested_closing_date).and_return(Time.new(2015,2,16))
      expect(subject.calculate_closing_plus_rescission_date.to_date).to eq(Date.new(2015,2,20))
    end
    it 'should return nil if no requested closing date' do
      subject.stub_chain(:loan_feature, :requested_closing_date).and_return(nil)
      expect(subject.calculate_closing_plus_rescission_date).to be_nil
    end
  end

  describe 'first_time_homebuyer?' do
    it 'no declarations' do
      subject.stub(:declarations).and_return([OpenStruct.new(:homeowner_past_three_years_type => 'Yes')])
      subject.first_time_homebuyer?.should be false
    end

    it 'is true from declarations' do
      subject.stub(:declarations).and_return([OpenStruct.new(:homeowner_past_three_years_type => 'No')])
      subject.first_time_homebuyer?.should be true
    end

    it 'is true from lock loan data' do
      subject.stub_chain(:lock_loan_datum, :first_time_homebuyer).and_return(true)
      subject.first_time_homebuyer?.should be true
    end
  end

  context "when locked_at is set and lock_expiration_at not in the past" do
    describe "locked_at set" do
      it 'is_locked?' do
        subject.locked_at = 3.days.ago
        subject.is_locked?.should be true
      end

      it 'rate_lock_status is Expired' do
        subject.locked_at = 3.days.ago
        subject.lock_expiration_at = nil
        subject.rate_lock_status.should eq('Locked')
      end
    end

    describe "lock_expiration_at set in future" do
      it 'is_locked?' do
        subject.locked_at = 3.days.ago
        subject.lock_expiration_at = Date.tomorrow
        subject.is_locked?.should be true
      end

      it 'rate_lock_status is Locked' do
        subject.locked_at = 3.days.ago
        subject.lock_expiration_at = Date.tomorrow
        subject.rate_lock_status.should eq('Locked')
      end
    end
  end

  context "when locked_at is set and lock_expiration_at is in the past" do
    it 'not is_locked?' do
      subject.locked_at = 3.days.ago
      subject.lock_expiration_at = Date.yesterday
      subject.is_locked?.should be false
    end

    it 'rate_lock_status is Expired' do
      subject.locked_at = 3.days.ago
      subject.lock_expiration_at = Date.yesterday
      subject.rate_lock_status.should eq('Expired')
    end
  end

  context "when locked_at is nil" do
    it 'not is_locked?' do
      subject.locked_at = nil
      subject.lock_expiration_at = nil
      subject.is_locked?.should be false
    end

    it 'rate_lock_status is Not Locked' do
      subject.locked_at = nil
      subject.lock_expiration_at = nil
      subject.rate_lock_status.should eq('Not Locked')
    end
  end

  it '#borrower_full_name' do
    subject.stub(:borrower_first_name).and_return('John')
    subject.stub(:borrower_last_name).and_return('Doe')
    subject.borrower_full_name.should eq('John Doe')
  end

  let(:loan) { FactoryGirl.build_stubbed(:loan) }

  it '#originator_replaced?' do
    loan.stub_chain(:loan_general, :loan_events).and_return([ 
      build_stubbed(:loan_event, event_description: 'Loan Transfer Completed blah'), 
      build_stubbed(:loan_event, event_description: 'blah blah blah') ])
    loan.originator_replaced?.should be true
  end

  describe '#gathering credit scores' do
    it "returns the borrowers credit score if it has one" do
      subject.stub_chain(:borrowers, :collect).and_return([500])
      subject.pe_credit_scores.should eq([500])
    end

    it "fetches the credit score from underwriting if a borrower does not have one" do
      subject.stub_chain(:borrowers, :collect).and_return([nil])
      subject.stub_chain(:loan_general, :underwriting_datum, :borrower_credit_score).and_return(600)
      subject.pe_credit_scores.should eq(600)
    end
  end

  describe '#ltv' do
    let(:loan_general) { FactoryGirl.build_stubbed(:loan_general) }
    let(:mortgage_term) { FactoryGirl.build_stubbed(:mortgage_term, base_loan_amount: 130000) }

    it "when product_code is not USDA30FXD and the purpose type is 'Purchase'" do
      subject.stub_chain(:loan_general, :product_code).and_return("USDA15FXD")
      subject.stub_chain(:loan_general, :loan_type).and_return("Purchase")
      subject.stub(:purchase_price_amount).and_return(150000)
      subject.stub(:property_appraised_value_amount).and_return(160000)
      subject.stub(:mortgage_term).and_return(mortgage_term)
      subject.ltv.should eq(86.667)
    end

    it "when product_code is not USDA30FXD and the purpose type is 'Refinance'" do
      subject.stub_chain(:loan_general, :product_code).and_return("USDA15FXD")
      subject.stub_chain(:loan_general, :loan_type).and_return("Refinance")
      subject.stub(:property_appraised_value_amount).and_return(150000)
      subject.stub(:mortgage_term).and_return(mortgage_term)
      subject.ltv.should eq(86.667)
    end

    it "when product_code is USDA30FXD and the purpose type is not 'Purchase' or 'Refinance'" do
      subject.stub_chain(:loan_general, :product_code).and_return("USDA30FXD")
      subject.stub_chain(:loan_general, :loan_type).and_return("ConstructionOnly")
      subject.stub(:property_appraised_value_amount).and_return(150000)
      subject.stub(:mortgage_term).and_return(mortgage_term)
      subject.ltv.should eq(86.667)
    end

    it "when product_code is not USDA30FXD and the purpose type is 'ConstructionOnly'" do
      subject.stub_chain(:loan_general, :product_code).and_return("USDA15FXD")
      subject.stub_chain(:loan_general, :loan_type).and_return("ConstructionOnly")
      subject.stub(:property_appraised_value_amount).and_return(150000)
      subject.stub(:mortgage_term).and_return(mortgage_term)
      subject.ltv.should eq(86.667)
    end

    it "when none of the conditions are met" do
      subject.stub_chain(:loan_general, :product_code).and_return("USDA15FXD")
      subject.stub_chain(:loan_general, :loan_type).and_return("SomeOtherType")
      subject.stub(:property_appraised_value_amount).and_return(150000)
      subject.stub(:mortgage_term).and_return(mortgage_term)
      subject.ltv.should eq(0)
    end
  end

  describe '#gse_property_type' do
    let(:loan_general) { FactoryGirl.build_stubbed(:loan_general) }

    it 'when lock_loan gse_property_type is set, it should prefer it' do
      subject.stub(:loan_general) { loan_general }
      loan_general.stub(:loan_feature) { build_stubbed(:loan_feature, gse_property_type: 'LOANF') }
      loan_general.stub(:additional_loan_datum) { build_stubbed(:additional_loan_datum, gse_property_type: 'ADDITLOAN') }
      loan_general.stub(:lock_loan_datum) { build_stubbed(:lock_loan_datum, gse_property_type: 'LOCLOAN') }
      subject.gse_property_type.should eq('LOCLOAN')
    end

    it 'when lock_loan gse_property_type is not set, it should prefer loan_feature' do
      subject.stub(:loan_general) { loan_general }
      loan_general.stub(:loan_feature) { build_stubbed(:loan_feature, gse_property_type: 'LOANF') }
      loan_general.stub(:additional_loan_datum) { build_stubbed(:additional_loan_datum, gse_property_type: 'ADDITLOAN') }
      loan_general.stub(:lock_loan_datum) { build_stubbed(:lock_loan_datum, gse_property_type: '') }
      subject.gse_property_type.should eq('LOANF')
    end

    it 'when neither loan_feature nor lock_loan gse_property_type is set, it should return nil' do
      subject.stub(:loan_general) { loan_general }
      loan_general.stub(:loan_feature) { build_stubbed(:loan_feature, gse_property_type: '') }
      loan_general.stub(:additional_loan_datum) { build_stubbed(:additional_loan_datum, gse_property_type: 'ADDITLOAN') }
      loan_general.stub(:lock_loan_datum) { build_stubbed(:lock_loan_datum, gse_property_type: '') }
      subject.gse_property_type.should eq(nil)
    end
  end

  describe "calculate_tandl_closing" do
    it 'should return sum of monthly amount if Hud lines which contains certain values for SystemFeeName and UserDefinedFeeName' do
      subject.stub(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: "Mortgage insurance", monthly_amt: BigDecimal.new("73",2), hud_type: 'HUD'), build_stubbed(:hud_line, sys_fee_name: "Mortgage insurance", monthly_amt: BigDecimal.new("83",2), hud_type: 'GFE'), build_stubbed(:hud_line, sys_fee_name: "Flood insurance", monthly_amt: BigDecimal.new("60",2), hud_type: 'HUD'), build_stubbed(:hud_line, user_def_fee_name: "Unit Tax", monthly_amt: BigDecimal.new("30",2), hud_type: 'HUD')]}
      expect(subject.calculate_tandl_closing).to eq(163.0)
    end 

    it 'should not include Hud lines for calculating sum which does not contain proper values' do
      subject.stub(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: "Mortgage", monthly_amt: BigDecimal.new("83",2), hud_type: 'HUD'), build_stubbed(:hud_line, sys_fee_name: "Mortgage insurance", hud_type: 'HUD'), build_stubbed(:hud_line, sys_fee_name: "Flood insurance", monthly_amt: BigDecimal.new("60",2), hud_type: 'HUD'), build_stubbed(:hud_line, user_def_fee_name: "Unit", monthly_amt: BigDecimal.new("30",2), hud_type: 'HUD')]}
      expect(subject.calculate_tandl_closing).to eq(60.0)
    end

    it 'should return null if Hud lines does not mtach with any of the value' do
      subject.stub(:hud_lines) {[build_stubbed(:hud_line, sys_fee_name: "Mortgage", monthly_amt: BigDecimal.new("83",2)), build_stubbed(:hud_line, sys_fee_name: "insurance", monthly_amt: BigDecimal.new("60",2)), build_stubbed(:hud_line, user_def_fee_name: "Unit Rate", monthly_amt: BigDecimal.new("30",2))]}
      expect(subject.calculate_tandl_closing).to be_nil
    end
  end

  describe "calculate_tandl_underwriting" do
    it 'should return total payment amount for the matched proposed housing expenses' do
      subject.stub(:proposed_housing_expenses) {[ build_stubbed(:proposed_housing_expense, housing_expense_type: "FirstMortgagePrincipalAndInterest", payment_amount: BigDecimal.new("83.333")), build_stubbed(:proposed_housing_expense, housing_expense_type: "HomeownersAssociationDuesAndCondominiumFees", payment_amount: BigDecimal.new("20.333")), build_stubbed(:proposed_housing_expense, housing_expense_type: "MI")]}
      expect(subject.calculate_tandl_underwriting).to eq(20.33)
    end

    it 'should return 0 if none of the HousingExpenseType matches' do
      subject.stub(:proposed_housing_expenses) {[ build_stubbed(:proposed_housing_expense, housing_expense_type: "FirstMortgage", payment_amount: BigDecimal.new("83.333")), build_stubbed(:proposed_housing_expense, housing_expense_type: "CondominiumFees", payment_amount: BigDecimal.new("20.333"))]}
      expect(subject.calculate_tandl_underwriting).to eq(0.0)
    end
  end  

  describe "mortgage_insurance_amount_1003" do
    it "should return 0 when nil" do
      subject.stub(:proposed_housing_expenses) {[ build_stubbed(:proposed_housing_expense, housing_expense_type: "FirstMortgagePrincipalAndInterest", payment_amount: BigDecimal.new("83.333")), build_stubbed(:proposed_housing_expense, housing_expense_type: "HomeownersAssociationDuesAndCondominiumFees", payment_amount: BigDecimal.new("20.333")), build_stubbed(:proposed_housing_expense, housing_expense_type: "MI", payment_amount: nil)]}
      expect(subject.mortgage_insurance_amount_1003).to eq(0.0)
    end

    it "should return value rounded to two decimals" do 
      subject.stub(:proposed_housing_expenses) {[ build_stubbed(:proposed_housing_expense, housing_expense_type: "FirstMortgagePrincipalAndInterest", payment_amount: BigDecimal.new("83.333")), build_stubbed(:proposed_housing_expense, housing_expense_type: "HomeownersAssociationDuesAndCondominiumFees", payment_amount: BigDecimal.new("20.333")), build_stubbed(:proposed_housing_expense, housing_expense_type: "MI", payment_amount: BigDecimal.new("20.567"))]}
      expect(subject.mortgage_insurance_amount_1003).to eq(20.57)
    end
  end

  describe "rate_lock_request_escrow_waiver" do
    it 'should return Yes if escrow_waiver_indicator is true' do
      subject.stub_chain(:lock_loan_datum, :escrow_waiver_indicator).and_return(true)
      expect(subject.rate_lock_request_escrow_waiver).to eq('Yes')
    end
    it 'should return No if escrow_waiver_indicator is false' do
      subject.stub_chain(:lock_loan_datum, :escrow_waiver_indicator).and_return(false)
      expect(subject.rate_lock_request_escrow_waiver).to eq('No')
    end
    it 'should return nil if escrow_waiver_indicator is blank' do
      subject.stub_chain(:lock_loan_datum, :escrow_waiver_indicator).and_return(nil)
      expect(subject.rate_lock_request_escrow_waiver).to be_nil
    end
  end

  describe "calculate sum_of_liquid_assets" do
    it 'should return the sum of all assets which match the asset type' do
      subject.stub(:assets) {[ build_stubbed(:asset, asset_type: "CheckingAccount", borrower_id: "BRW2", cash_amount: BigDecimal.new("88.09")), build_stubbed(:asset, asset_type: "GiftsNotDeposited", borrower_id: "BRW2", cash_amount: BigDecimal.new("5500.0")), build_stubbed(:asset, asset_type: "SavingsAccount", cash_amount: BigDecimal.new("88.09"))]}
      expect(subject.calculate_sum_of_liquid_assets).to eq(5588.09)
    end

    it 'should return the sum of all assets which match the asset type' do
      subject.stub(:assets) {[ build_stubbed(:asset, asset_type: "CheckingAccountChanged", borrower_id: "BRW2", cash_amount: BigDecimal.new("88.09")), build_stubbed(:asset, asset_type: "GiftsNotDeposited", borrower_id: "BRW6", cash_amount: BigDecimal.new("5500.0"))]}
      expect(subject.calculate_sum_of_liquid_assets).to be_nil
    end
  end

  describe "check underwriting condition expiration date" do

    it "should return date if the underwriting condition matched the content" do
      subject.stub(:underwriting_conditions) {[ build_stubbed(:underwriting_condition, condition: 'Asset Expiration: 08/07/2012', status: "Pending"), build_stubbed(:underwriting_condition, condition: 'Asset Expiration: 09/07/2012') ]}
      expect(subject.check_underwriting_condition_expiration_date('Asset Expiration')).to eq("08/07/2012")
    end

    it "should return nil if the underwriting condition has no matching expiration type" do
      subject.stub(:underwriting_conditions) {[ build_stubbed(:underwriting_condition, condition: 'Asset Expiration: 08/07/2012'), build_stubbed(:underwriting_condition, condition: 'Credit Report') ]}
      expect(subject.check_underwriting_condition_expiration_date('Title Expiration')).to be_nil
    end

    it "should return Latest underwriting_condition if there is no entry with status as pending" do
      subject.stub(:underwriting_conditions) {[ build_stubbed(:underwriting_condition, condition: 'Credit Report: 08/07/2012', status: "Waived"), build_stubbed(:underwriting_condition, condition: 'Credit Report 12/12/2014', status: "Approved") ]}
      expect(subject.check_underwriting_condition_expiration_date('Credit Report')).to eq("12/12/2014")
    end

    it 'should return nil if the date is not valid' do
      subject.stub(:underwriting_conditions) {[ build_stubbed(:underwriting_condition, condition: 'Asset Expiration: 888/07/2012' , status: "Pending"), build_stubbed(:underwriting_condition, condition: 'Credit Report') ]}
      expect(subject.check_underwriting_condition_expiration_date('Asset Expiration')).to be_nil
    end
  end

  describe "#trid_loan?" do
    let(:master_loan) {Master::Loan.new}
    before do
      loan.loan_num = 123
      Master::Loan.stub(:find_by).with(loan_num: 123).and_return(master_loan)
    end

    it "should return false if the application date is nil" do
      master_loan.stub application_date: nil
      expect(loan.trid_loan?).to eq false
    end

    it "should return false when the application date is before the TRID date" do
      master_loan.stub application_date: DateTime.new(2015,1,1)
      expect(loan.trid_loan?).to eq false
    end

    it "should return true if the application date is equal or greater than TRID date" do
      master_loan.stub application_date: TRID_DATE
      expect(loan.trid_loan?).to eq true

      master_loan.stub application_date: TRID_DATE + 1.days
      expect(loan.trid_loan?).to eq true    
    end
  end

  describe "hcltv regresion tests" do
    [["1022358", 95.0], ["1053697", 56.878], ["1030773", 79.0], ["1032348", 96.5], ["1058318", 77.931], ["1048180", 68.319], ["1053341", 56.863], ["1052653", 91.435], ["1078913", 80.0], ["1012046", 0], ["1087703", 71.897], ["1059509", 85.0], ["1090809", 56.41], ["1076527", 72.214], ["1044920", 100.487], ["1022716", 80.0], ["1022089", 84.722], ["1007201", 80.0], ["1035335", 68.421], ["1025416", 83.49], ["1081133", 84.881], ["1076068", 60.96], ["1039213", 43.333], ["1045436", 92.174], ["1072887", 82.252], ["1098489", 80.0], ["1089055", 96.5], ["1034570", 80.0], ["1088146", 105.0], ["1049910", 69.882], ["1068433", 96.5], ["1067270", 76.923], ["1003048", 89.825], ["1023480", 73.333], ["1078970", 56.075], ["1072798", 42.553], ["1056403", 96.154], ["1019936", 90.151], ["1095891", 80.0], ["1026878", 88.344], ["1059667", 95.0], ["1057176", 80.0], ["1013038", 55.556], ["1070324", 87.538], ["1021033", 96.5], ["1081097", 96.127], ["1002328", 73.841], ["1036918", 96.5], ["1028145", 96.5], ["1016968", 67.32], ["1032407", 75.0], ["1043992", 96.0], ["1088969", 87.815], ["1037772", 85.0], ["1015804", 96.5], ["1072368", 86.29], ["1094211", 41.667], ["1095477", 90.0], ["1034381", 80.0], ["1099133", 80.0], ["1069605", 80.0], ["1060149", 33.813], ["1083570", 80.244], ["1093784", 90.0], ["1057543", 38.359], ["1072750", 81.577], ["1076468", 95.992], ["1044641", 89.127], ["1041998", 43.714], ["1070742", 75.0], ["1016273", 76.478], ["1039780", 80.0], ["1044234", 76.174], ["1047702", 96.5], ["1085388", 96.499], ["1050898", 15.556], ["1006384", 66.316], ["1070472", 61.112], ["1081684", 80.015], ["1075627", 77.356], ["1020837", 96.5], ["1054012", 53.191], ["1009133", 75.0], ["1079142", 76.451], ["1035371", 96.5], ["1080047", 54.156], ["1084796", 96.5], ["1075339", 92.425], ["1005084", 43.077], ["1056807", 14.512], ["1083542", 76.757], ["1088817", 67.917], ["1052316", 59.778], ["1017489", 94.713], ["1058734", 95.0], ["1026491", 96.5], ["1036110", 64.324], ["1046311", 107.585], ["1006368", 74.0], ["1080415", 55.576]
    ].each do |loan_num, expected|
      it "should calculate hcltv for loan #{loan_num} as #{expected}" do
        loan = Loan.find_by loan_num: loan_num
        expect(loan.hcltv).to eq expected
      end
    end
  end

  describe "cltv regression tests" do
    [["1022358", 95.0], ["1053697", 56.878], ["1030773", 79.0], ["1032348", 96.5], ["1058318", 77.931], ["1048180", 68.319], ["1053341", 56.863], ["1052653", 91.435], ["1078913", 80.0], ["1012046", 0], ["1087703", 71.897], ["1059509", 85.0], ["1090809", 56.41], ["1076527", 72.214], ["1044920", 100.487], ["1022716", 80.0], ["1022089", 84.722], ["1007201", 80.0], ["1035335", 68.421], ["1025416", 83.49], ["1081133", 84.881], ["1076068", 60.96], ["1039213", 43.333], ["1045436", 92.174], ["1072887", 82.252], ["1098489", 80.0], ["1089055", 96.5], ["1034570", 80.0], ["1088146", 105.0], ["1049910", 69.882], ["1068433", 96.5], ["1067270", 76.923], ["1003048", 89.825], ["1023480", 73.333], ["1078970", 56.075], ["1072798", 42.553], ["1056403", 96.154], ["1019936", 90.151], ["1095891", 80.0], ["1026878", 88.344], ["1059667", 95.0], ["1057176", 80.0], ["1013038", 55.556], ["1070324", 87.538], ["1021033", 96.5], ["1081097", 96.127], ["1002328", 73.841], ["1036918", 96.5], ["1028145", 96.5], ["1016968", 67.32], ["1032407", 75.0], ["1043992", 96.0], ["1088969", 87.815], ["1037772", 85.0], ["1015804", 96.5], ["1072368", 86.29], ["1094211", 41.667], ["1095477", 90.0], ["1034381", 80.0], ["1099133", 80.0], ["1069605", 80.0], ["1060149", 33.813], ["1083570", 80.244], ["1093784", 90.0], ["1057543", 38.359], ["1072750", 81.577], ["1076468", 95.992], ["1044641", 89.127], ["1041998", 43.714], ["1070742", 75.0], ["1016273", 76.478], ["1039780", 80.0], ["1044234", 76.174], ["1047702", 96.5], ["1085388", 96.499], ["1050898", 15.556], ["1006384", 66.316], ["1070472", 61.112], ["1081684", 80.015], ["1075627", 77.356], ["1020837", 96.5], ["1054012", 53.191], ["1009133", 75.0], ["1079142", 76.451], ["1035371", 96.5], ["1080047", 54.156], ["1084796", 96.5], ["1075339", 92.425], ["1005084", 43.077], ["1056807", 14.512], ["1083542", 76.757], ["1088817", 67.917], ["1052316", 59.778], ["1017489", 94.713], ["1058734", 95.0], ["1026491", 96.5], ["1036110", 64.324], ["1046311", 107.585], ["1006368", 74.0], ["1080415", 55.576]
    ].each do |loan_num, expected|
      it "should calculate cltv for loan #{loan_num} as #{expected}" do
        loan = Loan.find_by loan_num: loan_num
        expect(loan.cltv).to eq expected
      end
    end
  end

  describe "ltv regression tests" do
    [["1022358", 95.0], ["1053697", 56.878], ["1030773", 79.0], ["1032348", 96.5], ["1058318", 77.931], ["1048180", 68.319], ["1053341", 56.863], ["1052653", 63.657], ["1078913", 80.0], ["1012046", 0], ["1087703", 71.897], ["1059509", 85.0], ["1090809", 56.41], ["1076527", 47.657], ["1044920", 47.153], ["1022716", 49.623], ["1022089", 84.722], ["1007201", 80.0], ["1035335", 68.421], ["1025416", 83.49], ["1081133", 77.254], ["1076068", 60.96], ["1039213", 43.333], ["1045436", 92.174], ["1072887", 80.0], ["1098489", 80.0], ["1089055", 96.5], ["1034570", 80.0], ["1088146", 105.0], ["1049910", 69.882], ["1068433", 96.5], ["1067270", 76.923], ["1003048", 64.154], ["1023480", 73.333], ["1078970", 56.075], ["1072798", 42.553], ["1056403", 96.154], ["1019936", 83.699], ["1095891", 80.0], ["1026878", 88.344], ["1059667", 95.0], ["1057176", 80.0], ["1013038", 55.556], ["1070324", 87.538], ["1021033", 96.5], ["1081097", 96.127], ["1002328", 57.016], ["1036918", 96.5], ["1028145", 96.5], ["1016968", 67.32], ["1032407", 75.0], ["1043992", 96.0], ["1088969", 41.294], ["1037772", 85.0], ["1015804", 96.5], ["1072368", 86.29], ["1094211", 41.667], ["1095477", 90.0], ["1034381", 80.0], ["1099133", 80.0], ["1069605", 80.0], ["1060149", 33.813], ["1083570", 65.968], ["1093784", 90.0], ["1057543", 26.364], ["1072750", 70.038], ["1076468", 95.992], ["1044641", 89.127], ["1041998", 43.714], ["1070742", 75.0], ["1016273", 76.478], ["1039780", 80.0], ["1044234", 76.174], ["1047702", 96.5], ["1085388", 96.499], ["1050898", 15.556], ["1006384", 66.316], ["1070472", 61.112], ["1081684", 71.176], ["1075627", 51.163], ["1020837", 96.5], ["1054012", 53.191], ["1009133", 75.0], ["1079142", 76.451], ["1035371", 96.5], ["1080047", 54.156], ["1084796", 96.5], ["1075339", 92.425], ["1005084", 43.077], ["1056807", 14.512], ["1083542", 76.757], ["1088817", 67.917], ["1052316", 47.273], ["1017489", 94.713], ["1058734", 80.0], ["1026491", 96.5], ["1036110", 64.324], ["1046311", 96.235], ["1006368", 74.0], ["1080415", 55.576]
    ].each do |loan_num, expected|
      it "should calculate ltv for loan #{loan_num} as #{expected}" do
        loan = Loan.find_by loan_num: loan_num
        expect(loan.ltv).to eq expected
      end
    end
  end

  describe "mi_ltv regression tests including ltv fallback" do
    [["1022358", 95.0], ["1053697", 56.878], ["1030773", 79.0], ["1032348", 96.5], ["1058318", 77.931], ["1048180", 68.319], ["1053341", 56.863], ["1052653", 63.657], ["1078913", 80.0], ["1012046", 0], ["1087703", 71.897], ["1059509", 85.0], ["1090809", 56.41], ["1076527", 47.657], ["1044920", 47.153], ["1022716", 49.623], ["1022089", 84.722], ["1007201", 80.0], ["1035335", 68.421], ["1025416", 83.49], ["1081133", 77.254], ["1076068", 60.96], ["1039213", 43.333], ["1045436", 92.174], ["1072887", 80.0], ["1098489", 80.0], ["1089055", 96.5], ["1034570", 80.0], ["1088146", 105.0], ["1049910", 69.882], ["1068433", 96.5], ["1067270", 76.923], ["1003048", 64.154], ["1023480", 73.333], ["1078970", 56.075], ["1072798", 42.553], ["1056403", 96.154], ["1019936", 83.699], ["1095891", 80.0], ["1026878", 88.344], ["1059667", 95.0], ["1057176", 80.0], ["1013038", 55.556], ["1070324", 87.538], ["1021033", 96.5], ["1081097", 96.127], ["1002328", 57.016], ["1036918", 96.5], ["1028145", 96.5], ["1016968", 67.32], ["1032407", 75.0], ["1043992", 96.0], ["1088969", 41.294], ["1037772", 85.0], ["1015804", 96.5], ["1072368", 86.29], ["1094211", 41.667], ["1095477", 90.0], ["1034381", 80.0], ["1099133", 80.0], ["1069605", 78.2], ["1060149", 33.813], ["1083570", 65.968], ["1093784", 90.0], ["1057543", 26.364], ["1072750", 70.038], ["1076468", 95.992], ["1044641", 89.127], ["1041998", 43.714], ["1070742", 75.0], ["1016273", 76.478], ["1039780", 80.0], ["1044234", 76.174], ["1047702", 96.5], ["1085388", 96.499], ["1050898", 15.556], ["1006384", 66.316], ["1070472", 61.112], ["1081684", 71.176], ["1075627", 51.163], ["1020837", 96.5], ["1054012", 53.191], ["1009133", 75.0], ["1079142", 76.451], ["1035371", 96.5], ["1080047", 54.156], ["1084796", 96.5], ["1075339", 92.425], ["1005084", 43.077], ["1056807", 14.512], ["1083542", 76.757], ["1088817", 67.917], ["1052316", 47.273], ["1017489", 94.713], ["1058734", 80.0], ["1026491", 96.5], ["1036110", 64.324], ["1046311", 96.235], ["1006368", 74.0], ["1080415", 55.576]
    ].each do |loan_num, expected|
      it "should calculate mi_ltv for loan #{loan_num} as #{expected}" do
        loan = Loan.find_by loan_num: loan_num
        expect(loan.mi_ltv).to eq expected
      end
    end
  end

  describe "mi_ltv regression tests no ltv fallback" do
    [["1047702", 96.5], ["1020761", 95.381], ["1096859", 91.164], ["1012077", 95.849], ["1050187", 79.71], ["1006275", 88.5], ["1049732", 102.041], ["1096704", 80.0], ["1033351", 45.455], ["1095532", 87.648], ["1040459", 93.348], ["1016455", 95.545], ["1021974", 80.0], ["1083342", 80.0], ["1097185", 79.656], ["1077717", 96.5], ["1025424", 96.017], ["1035495", 96.5], ["1005956", 96.5], ["1009233", 90.0], ["1011183", 81.542], ["1070857", 89.808], ["1005244", 79.086], ["1015672", 77.46], ["1048207", 80.0], ["1016939", 96.411], ["1095628", 95.869], ["1036508", 94.598], ["1040321", 76.667], ["1087257", 102.041], ["1020803", 96.5], ["1099709", 95.081], ["1094241", 75.0], ["1074157", 94.776], ["1021407", 95.0], ["1050499", 77.714], ["1033877", 96.433], ["1058693", 96.448], ["1069207", 80.0], ["1035573", 78.0], ["1022865", 0], ["1091646", 96.5]
    ].each do |loan_num, expected|
      it "should calculate mi_ltv for loan #{loan_num} as #{expected}" do
        loan = Loan.find_by loan_num: loan_num
        expect(loan.mi_ltv).to eq expected
      end
    end 
  end

  describe "cltv" do
    let(:loan_general) { build_stubbed(:loan_general) }
    let(:mortgage_term) { build_stubbed :mortgage_term }
    before do
      loan.stub loan_general: loan_general, mortgage_term: mortgage_term, purchase_price_amount: 0,
        property_appraised_value_amount: 0, property_estimated_value_amount: 0,
        mi_and_funding_fee_total_amount: 0
      loan.stub_chain(:liabilities, :resubordinate_mortgage_loan).and_return(0)
    end

    it "should get value from calculator" do
      Cltv.any_instance.stub call: 97.456
      expect(loan.cltv).to eq 97.456
    end

    it "should pass product code to calculator" do
      loan_general.stub product_code: "foo"
      Cltv.any_instance.stub :call do |calculator|
        expect(calculator.product_code).to eq "foo"
      end
      loan.cltv
    end

    it "should pass purpose_type to calculator" do
      loan_general.stub loan_type: "foo"
      Cltv.any_instance.stub :call do |calculator|
        expect(calculator.purpose_type).to eq "foo"
      end
      loan.cltv
    end

    it "should pass base_loan_amount from mortgage term" do
      mortgage_term.stub base_loan_amount: 123.45
      Cltv.any_instance.stub :call do |calculator|
        expect(calculator.base_loan_amount).to eq 123.45
      end
      loan.cltv
    end

    it "should not die if there is no mortgage_term" do
      loan.stub mortgage_term: nil
      loan.cltv
    end

    it "should pass the purchase_price_amount" do
      loan.stub purchase_price_amount: 500.01
      Cltv.any_instance.stub :call do |calculator|
        expect(calculator.purchase_price_amount).to eq 500.01
      end
      loan.cltv
    end

    it "should pass the property appraised amount if present" do
      loan.stub property_appraised_value_amount: 123.45, property_estimated_value_amount: 100.00
      Cltv.any_instance.stub :call do |calculator|
        expect(calculator.property_appraised_value_amount).to eq 123.45
      end
      loan.cltv
    end

    it "should pass the property estimated amount if appraised is missing" do
      loan.stub property_appraised_value_amount: nil, property_estimated_value_amount: 100.00
      Cltv.any_instance.stub :call do |calculator|
        expect(calculator.property_appraised_value_amount).to eq 100.00
      end
      loan.cltv
    end

    it "should pass the subordinate_lien_amount from loan_general" do
      loan_general.stub subordinate_lien_amount: 555.66
      Cltv.any_instance.stub :call do |calculator|
        expect(calculator.subordinate_lien_amount).to eq 555.66
      end
      loan.cltv
    end

    it "should pass liability amount from resubordinate_mortgage_loan, whatever that is" do
      loan.stub_chain(:liabilities, :resubordinate_mortgage_loan).and_return(999.87)
      Cltv.any_instance.stub :call do |calculator|
        expect(calculator.liability_amount).to eq 999.87
      end
      loan.cltv
    end

    it "should pass the mi_and_funding_fee_total_amount" do
      loan.stub mi_and_funding_fee_total_amount: 555.66
      Cltv.any_instance.stub :call do |calculator|
        expect(calculator.mi_and_funding_fee_total_amount).to eq 555.66
      end
      loan.cltv
    end
  end

  describe "scope .trid" do

    it "should only return loans applied for on or after the TRID cutover" do
      ids = Loan.trid.pluck(:id)
      loans = Loan.find ids
      errors = []
      loans.each do |loan|
        date = loan.loan_general.application_date
        errors << date if date < TRID_DATE
      end
      expect(errors).to be_empty
    end

  end

  describe "scope .cancelled_or_denied" do

    it "should only return loans that were cancelled, withdrawn, or denied" do
      loans = Loan.cancelled_or_denied.includes(:denial_letter).limit(100)
      errors = []
      loans.each do |loan|
        letter = loan.denial_letter
        errors << loan.loan_num if letter.cancel_withdrawn_at.nil? && letter.denied_at.nil?
      end
      expect(errors).to be_empty
    end

  end

  describe "scope .applied_between" do

    it "should return loans of a single date search" do
      date = Date.new(2015,6,27)
      ids = Loan.applied_between(date, date).pluck(:id)
      loans = Loan.find ids
      errors = []
      loans.each do |loan|
        app_date = loan.loan_general.application_date
        errors << app_date if app_date.end_of_day != date.end_of_day
      end
      expect(errors).to be_empty
    end

    it "should return loans between two dates, inclusive" do
      start_date = Date.new(2015,6,28)
      end_date = Date.new(2015,7,1)
      ids = Loan.applied_between(start_date, end_date).pluck(:id)
      loans = Loan.find ids
      errors = []
      loans.each do |loan|
        date = loan.loan_general.application_date
        errors << date if date < start_date.beginning_of_day || date > end_date.end_of_day
      end
      expect(errors).to be_empty
    end

  end

  describe ".denied_cancelled_withdrawn?" do

    it "should require a denial letter" do
      subject.stub(:denial_letter).and_return nil

      expect(subject.denied_cancelled_withdrawn?).to be_falsey
    end

    it "should accept a cancel/withrawn date" do
      letter = double
      allow(letter).to receive(:cancel_withdrawn_at).and_return(Date.yesterday)
      allow(letter).to receive(:denied_at).and_return(nil)
      subject.stub(:denial_letter).and_return letter

      expect(subject.denied_cancelled_withdrawn?).to be_truthy
    end

    it "should accept a denial date" do
      letter = double
      allow(letter).to receive(:cancel_withdrawn_at).and_return(nil)
      allow(letter).to receive(:denied_at).and_return(Date.yesterday)
      subject.stub(:denial_letter).and_return letter

      expect(subject.denied_cancelled_withdrawn?).to be_truthy
    end

    it "requires either a cancel/withdrawn date or a denial date" do
      letter = double
      allow(letter).to receive(:cancel_withdrawn_at).and_return(nil)
      allow(letter).to receive(:denied_at).and_return(nil)
      subject.stub(:denial_letter).and_return letter

      expect(subject.denied_cancelled_withdrawn?).to be_falsey
    end

  end

  describe "comp_tier" do
    let(:comp_tier) { double("CompTier") }
    let (:comptiers) { [
          CompTier.new({id: 1, effective_at: DateTime.new(2015,9,1).utc, effective_until: DateTime.new(2016,1,1).utc}, without_protection: true),
          CompTier.new({id: 2, effective_at: DateTime.new(2016,1,2).utc, effective_until: nil}, without_protection: true),
        ]}
    before do
      subject.stub is_wholesale?: true
      subject.stub lock_price: FactoryGirl.build_stubbed(:lock_price)
    end

    it "should be nil if the loan is not wholesale" do
      subject.stub is_wholesale?: false
      expect(subject.comp_tier).to be_nil
    end

    context "when the loan is locked" do
      before do
        subject.stub_chain(:lock_price, locked_at: DateTime.now.utc)
        subject.lock_price.stub is_loan_locked?: true 
      end
      it "should return the comp tier which is for locked time" do
        allow(comp_tier).to receive(:where).with("effective_at <= ?", subject.lock_price.locked_at).and_return(comptiers)
        allow(comptiers).to receive(:where).with("effective_until IS NULL OR effective_until >= ?", subject.lock_price.locked_at).and_return([CompTier.new({id: 2, effective_at: DateTime.new(2016,1,2).utc, effective_until: nil}, without_protection: true)])
        subject.stub_chain(:loan_general, :institution, :comp_tiers).and_return comp_tier
        
        expect(subject.comp_tier.id).to eq 2
        expect(subject.comp_tier.effective_at).to be <= subject.lock_price.locked_at
        expect(subject.comp_tier.effective_until).to be_nil
      end

      it "should return the matching comp tier when there are future ones" do
        subject.stub_chain(:lock_price, locked_at: DateTime.new(2015,10,8).utc)
        allow(comp_tier).to receive(:where).with("effective_at <= ?", subject.lock_price.locked_at).and_return(comptiers)
        allow(comptiers).to receive(:where).with("effective_until IS NULL OR effective_until >= ?", subject.lock_price.locked_at).and_return([CompTier.new({id: 1, effective_at: DateTime.new(2015,9,1).utc, effective_until: DateTime.new(2016,1,1).utc}, without_protection: true)])
        subject.stub_chain(:loan_general, :institution, :comp_tiers).and_return comp_tier
        
        expect(subject.comp_tier.id).to eq 1
        expect(subject.comp_tier.effective_at).to be <= subject.lock_price.locked_at
        expect(subject.comp_tier.effective_until).to be >= subject.lock_price.locked_at
      end
    end

    context "when loan is not locked" do
      before { subject.lock_price.stub is_loan_locked?: false }
      it "should return the comp tier which is valid for current time period" do
        allow(comp_tier).to receive(:where).with("effective_at <= ?", Date.today).and_return(comptiers)
        allow(comptiers).to receive(:where).with("effective_until IS NULL OR effective_until >= ?", Date.today).and_return([CompTier.new({id: 2, effective_at: DateTime.new(2016,1,2).utc, effective_until: nil}, without_protection: true)])
        subject.stub_chain(:loan_general, :institution, :comp_tiers).and_return comp_tier
        
        expect(subject.comp_tier.id).to eq 2
        expect(subject.comp_tier.effective_at).to be <= DateTime.now.utc
        expect(subject.comp_tier.effective_until).to be_nil
      end
    end

    context "when loan has no data" do
      before do
        allow(comp_tier).to receive(:where).with("effective_at <= ?", Date.today).and_return([])
        allow(comptiers).to receive(:where).with("effective_until IS NULL OR effective_until >= ?", Date.today).and_return([])
      end
      it "should not die if institution is nil" do
        subject.stub_chain(:loan_general, :institution).and_return nil
        expect(subject.comp_tier).to eq nil
      end

      it "should not die if comp_tiers are empty" do
        subject.stub_chain(:loan_general, :institution, :comp_tiers).and_return CompTier.none
        expect(subject.comp_tier).to eq nil
      end
    end
  end

end
