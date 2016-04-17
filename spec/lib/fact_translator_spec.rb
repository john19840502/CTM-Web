require 'spec_helper'

describe FactTranslator do
  context 'it translates the data' do
    it "when i want to original a translation for 'Detached Condo'" do
      expect(FactTranslator.property_type('Detached Condo')).to eq('Site Condo')
    end

    it "when i want to original a translation for 'Conforming 30yr Fixed High Balance'" do
      expect(FactTranslator.loan_product_name('Conforming 30yr Fixed High Balance')).to eq('C30FXD HIBAL')
    end

    it "when i want to original a translation for 'C30FXD HIBAL'" do
      expect(FactTranslator.loan_product_name('C30FXD HIBAL')).to eq('C30FXD HIBAL')
    end

    it "when number of units is 0" do
      expect(FactTranslator.number_of_units(0)).to eq(nil)
    end

    it "when number of units is 1" do
      expect(FactTranslator.number_of_units(1)).to eq(1)
    end
  end

  context "fact type regression tests" do
    describe "PURPOSE OF REFINANCE" do
      {
        ["Cash-Out/Debt Consolidation", "CashOutDebtConsolidation"] => "Cash-Out/Debt Consolidation", 
        ["Cash-Out/Home Improvement", "CashOutHomeImprovement"] => "Cash-Out/Home Improvement", 
        ["Cash-Out/Other", "CashOutOther"] => "Cash-Out/Other", 
        ["Limited Cash-Out", "CashOutLimited"] => "Limited Cash-Out", 
        ["No Cash-Out Rate/Term", "NoCashOutStreamlinedRefinance", "ChangeInRateTerm", "NoCashOutFHAStreamlinedRefinance", "VAStreamlinedRefinance"] => "No Cash-Out Rate/Term"
      }.each do |originals, answer|
        originals.each do |original|
          it "should return #{answer} for #{original}" do
            expect(FactTranslator.purpose_of_refinance(original)).to eq(answer)
          end
        end
      end
    end

    describe "PROPERTY TYPE INDICATOR" do
      {
        ["PUD Attached", "Attached", "PUDAttached"] => "PUD Attached", 
        ["Condominium", "Condominium"] => "Condominium", 
        ["PUD Detached", "Detached", "PUDDetached"] => "PUD Detached", 
        ["Manufactured House Singlewide", "ManufacturedHousingSingle"] => "Manufactured House Singlewide", 
        ["Manufactured House Multiwide", "ManufacturedHomeMultiwide"] => "Manufactured House Multiwide"
      }.each do |originals, answer|
        originals.each do |original|
          it "should return #{answer} for #{original}" do
            expect(FactTranslator.property_type_indicator(original)).to eq(answer)
          end
        end
      end
    end

    describe "PROJECT CLASSIFICATION" do
      {
        ["Streamlined Review"] => "Streamlined Review", 
        ["2 to 4 unit Project", "2- to 4-unit Project", "2- to 4-unit Project"] => "2 to 4 unit Project", 
        ["Detached Project"] => "Detached Project", 
        ["Established Project"] => "Established Project", 
        ["New Project"] => "New Project", 
        ["Reciprocal Review"] => "Reciprocal Review", 
        ["P Limited Review New", "P Limited Review New Detached", "PCondominium"] => "P Limited Review New", 
        ["Q Limited Review Est.", "Q Limited Review Established", "QCondominium"] => "Q Limited Review Est.", 
        ["R Expedited New", "R Expedited Review New", "RCondominium"] => "R Expedited New", 
        ["S Expedited Est.", "S Expedited Review Established", "SCondominium"] => "S Expedited Est.", 
        ["T Fannie Mae Review"] =>  "T Fannie Mae Review", 
        ["TCondominium"] => "T Fannie Mae Review", 
        ["U FHA-Approved", "UCondominium"] => "U FHA-Approved", 
        ["V Refi Plus"] => "V Refi Plus", 
        ["V Condo"] => "V Condo", 
        ["E PUD", "E_PUD"] => "E PUD", 
        ["F PUD", "F_PUD"] => "F PUD", 
        ["T PUD"] =>  "T PUD", 
        ["1 Co-Op", "1 CO-OP", "OneCooperative"] => "1 Co-Op", 
        ["2 Co-Op", "2 CO-OP", "TwoCooperative"] => "2 Co-Op", 
        ["T Co-Op", "T CO-OP"] => "T Co-Op"
      }.each do |originals, answer|
        originals.each do |original| 
          it "should return #{answer} for #{original}" do
            expect(FactTranslator.project_classification(original)).to eq(answer)
          end
        end
      end
    end

    describe "LOAN PRODUCT NAME" do
      {
        ["C15FXD", "Conforming 15yr Fixed"] => "C15FXD", 
        ["C15FXD HIBAL", "Conforming 15yr Fixed High Balance"] => "C15FXD HIBAL", 
        ["C20FXD RP", "Conforming 20yr Fixed DU RefiPlus"] => "C20FXD RP", 
        ["C20FXD HIBAL", "Conforming 20yr Fixed High Balance"] => "C20FXD HIBAL", 
        ["C30FXD", "Conforming 30yr Fixed"] => "C30FXD", 
        ["C30FXD RP", "Conforming 30yr Fixed DU RefiPlus"] => "C30FXD RP", 
        ["C30FXD HIBAL", "Conforming 30yr Fixed High Balance"] => "C30FXD HIBAL", 
        ["J30FXD", "Jumbo 30yr Fixed"] => "J30FXD", 
        ["J5/1ARM LIBOR", "Jumbo 5/1 ARM LIBOR", "J5/1ARM LIB"] => "J5/1ARM LIBOR", 
        ["J7/1ARM LIBOR", "Jumbo 7/1 ARM LIBOR", "J7/1 ARM LIB"] => "J7/1ARM LIBOR", 
        ["FHA15FXD", "FHA 15yr Fixed 203b"] => "FHA15FXD", 
        ["J15FXD", "Jumbo 15yr Fixed"] => "J15FXD", 
        ["VA15FXD", "VA 15yr Fixed"] => "VA15FXD", 
        ["VA30IRRRL", "VA 30yr IRRL"] => "VA30IRRRL", 
        ["USDA30FXD", "USDA 30yr Fixed"] => "USDA30FXD", 
        ["C20FXD Freddie Relief", "Conforming 20yr Fixed Freddie Mac Relief", "C20FXD FR"] => "C20FXD Freddie Relief", 
        ["C30FXD Freddie Relief", "Conforming 30yr Fixed Freddie Mac Relief", "C30FXD FR"] => "C30FXD Freddie Relief", 
        ["VA30FXD", "VA 30yr Fixed"] => "VA30FXD", 
        ["C30FXD HomePath", "Conforming 30yr Fixed HomePath", "C30FXD HP"] => "C30FXD HomePath", 
        ["C10/1ARM LIBOR", "Conforming 10/1 ARM LIBOR"] => "C10/1ARM LIBOR", 
        ["C10/1ARM LIB HIBAL", "Conforming 10/1 ARM LIBOR High Balance"] => "C10/1ARM LIB HIBAL", 
        ["C5/1ARM LIBOR", "Conforming 5/1 ARM LIBOR", "C5/1ARM LIB"] => "C5/1ARM LIBOR", 
        ["C5/1ARM LIB HIBAL", "Conforming 5/1 ARM LIBOR High Balance"] => "C5/1ARM LIB HIBAL", 
        ["C7/1ARM LIBOR", "Conforming 7/1 ARM LIBOR", "C7/1ARM LIB"] => "C7/1ARM LIBOR", 
        ["C7/1ARM LIB HIBAL", "Conforming 7/1 ARM LIBOR High Balance"] => "C7/1ARM LIB HIBAL", 
        ["C20FXD", "Conforming 20yr Fixed"] => "C20FXD", 
        ["C15FXD RP", "Conforming 15yr Fixed DU RefiPlus"] => "C15FXD RP", 
        ["C15FXD Freddie Relief", "Conforming 15yr Fixed Freddie Mac Relief", "C15FXD FR"] => "C15FXD Freddie Relief", 
        ["FHA Streamline", "FHA 30yr Streamline Refi", "FHA30STR"] => "FHA Streamline", 
        ["MSHDA-FHA 30 Fixed", "State Housing FHA 30yr Fixed MSHDA", "FHA30 MSHDA"] => "MSHDA-FHA 30 Fixed", 
        ["FHA30FXD", "FHA 30yr Fixed 203b"] => "FHA30FXD", 
        ["FHA 30 IHCDA IN NH", "State Housing FHA 30yr Fixed - IN Next Home"] => "FHA 30 IHCDA IN NH", 
        ["FHA 30 IHDA IL SM", "State Housing FHA 30yr Fixed - IL SmartMove"] => "FHA 30 IHDA IL SM", 
        ["C30FXD RP CD", "Conforming 30yr Fixed RefiPlus Consumer Direct"] => "C30FXD RP CD", 
        ["C15FXD RP CD", "Conforming 15yr Fixed RefiPlus Consumer Direct"] => "C15FXD RP CD", 
        ["C30FXD MCM", "Conforming 30yr Fixed My Community Mortgage"] => "C30FXD MCM", 
        ["FHA30 MSHDA NH"] => "FHA30 MSHDA NH", 
        ["J10/1ARM LIBOR", "J10/1 ARM LIB"] => "J10/1ARM LIBOR", 
        ["C30FXD IHDA IL"] => "C30FXD IHDA IL", 
        ["C30FXD IHDA IL FH"] => "C30FXD IHDA IL FH", 
        ["FHA30 IHDA IL FH"] => "FHA30 IHDA IL FH",
        ['FHA30 GA Dream'] => 'FHA30 GA Dream',
        ['FHA30 GA CHOICE'] => 'FHA30 GA Dream CHOICE',
        ['FHA30 GA PEN'] => 'FHA30 GA Dream PEN',
         ['C30FXD KY HC'] => 'C30FXD KHC',
        ['FHA30 KY HC'] => 'FHA30FXD KHC',
        ['FHA15STR'] => 'FHA15STR'
      }.each do |originals, answer|
        originals.each do |original|
          it "should return #{answer} for #{original}" do
            expect(FactTranslator.loan_product_name(original)).to eq(answer)
          end
        end
      end
    end

    describe "PURPOSE OF LOAN" do
      {
        ["Construction", "ConstructionOnly"] => "Construction", 
        ["Construction-Permanent", "ConstructionToPermanent"] => "Construction-Permanent", 
        ["Other"] => "Other", 
        ["Purchase"] => "Purchase", 
        ["Refinance"] => "Refinance"
      }.each do |originals, answer|
        originals.each do |original|
          it "should return #{answer} for #{original}" do
            expect(FactTranslator.purpose_of_loan(original)).to eq(answer)
          end
        end
      end
    end

    describe "ARM INDEX CODE" do
      {
        ["1-Year Treasury", "OneYearTreasury"] => "1-Year Treasury", 
        ["3-Year Treasury", "ThreeYearTreasury"] => "3-Year Treasury", 
        ["6-Month T-Bill", "SixMonthTreasury"] => "6-Month T-Bill", 
        ["LIBOR"] => "LIBOR", 
        ["National Median COF", "NationalMonthlyMedianCostOfFunds"] => "National Median COF", 
        ["COFI", "EleventhDistrictCostOfFunds"] => "COFI", 
        ["Other"] => "Other"
      }.each do |originals, answer|
        originals.each do |original|
          it "should return #{answer} for #{original}" do
            expect(FactTranslator.arm_index_code(original)).to eq(answer)
          end
        end
      end
    end

    describe "CHANNEL NAME" do
      {
        ["Consumer Direct", "C0-Consumer Direct Standard", "TC0-Test Consumer Direct Standard"] => "Consumer Direct", 
        ["Mini Correspondent", "R0-Reimbursement Standard", "TR0-Test Reimbursement Standard"] => "Mini Correspondent", 
        ["Private Banking", "P0-Private Banking Standard", "TP0-Test Private Banking"] => "Private Banking", 
        ["Retail", "A0-Affiliate Standard", "A4-Affiliate Tier 4", "Retail Channel", "TA0-Test Affiliate Standard", "TA1-Test Affiliate Tier 1 Dodd Frank"] => "Retail", 
        ["Wholesale", "TW0-Test Wholesale Standard", "TW1-Test Wholesale Dodd Frank", "TWC1 - Test Wholesale Borrower Paid Channel", "W0-Wholesale Standard", "W4-Wholesale Tier 4"] => "Wholesale"
      }.each do |originals, answer|
        originals.each do |original|
          it "should return #{answer} for #{original}" do
            expect(FactTranslator.channel_name(original)).to eq(answer)
          end
        end
      end
    end

    describe "HARP TYPE OF MI" do
      {
        ["Required Field Please Select", "null", "Required Field, Please Select..."] => "Required Field Please Select", 
        ["This is a non HARP Loan", "Non Harp", "Non HARP"] => "This is a non HARP Loan", 
        ["Borrower Paid Monthly MI", "Borrower Paid Monthly", "Borrower Paid, Monthly MI"] => "Borrower Paid Monthly MI", 
        ["Borrower Paid Single Premium - Paid Up Front", "Borrower Paid Single", "Borrower Paid, Single Premium - Paid Up Front"] => "Borrower Paid Single Premium - Paid Up Front", 
        ["Lender Paid Single Premium - Paid Up Front", "Lender Paid Single", "Lender Paid, Single Premium - Paid Up Front"] => "Lender Paid Single Premium - Paid Up Front", 
        ["No MI is required on the AUS", "No MI"] => "No MI is required on the AUS", 
        ["MI was cancelled documentation provided in imaging", "MI Cancelled", "MI was cancelled, documentation provided in imaging", "MI was cancelled, documentation provided in imagin"] => "MI was cancelled documentation provided in imaging"
      }.each do |originals, answer|
        originals.each do |original|
          it "should return #{answer} for #{original}" do
            expect(FactTranslator.harp_type_of_mi(original)).to eq(answer)
          end
        end
      end
    end

    describe "REQUESTED MORTGAGE INSURANCE TYPE" do
      {
        ["Borrower Paid MONTHLY", "Monthly", "B"] => "Borrower Paid MONTHLY", 
        ["Required Field Please Select", "null", "Required Field Please Select..."] => "Required Field Please Select", 
        ["No MI Required", "None", "Not Required", "NA"] => "No MI Required", 
        ["Lender Paid SINGLE Premium (LPMI)", "Lender", "Lender Paid SINGLE Premium", "L"]  => "Lender Paid SINGLE Premium (LPMI)", 
        ["Borrower Paid SPLIT Premium MI", "Split"] => "Borrower Paid SPLIT Premium MI"
      }.each do |originals, answer|
        originals.each do |original|
          it "should return #{answer} for #{original}" do
            expect(FactTranslator.requested_mortgage_insurance_type(original)).to eq(answer)
          end
        end
      end
    end

    describe "OCCUPANCY TYPE" do
      {
        ["Second Home", "SecondHome"] => "Second Home", 
        ["Primary", "PrimaryResidence"] => "Primary", 
        ["Investment", "Investor"] => "Investment"
      }.each do |originals, answer|
        originals.each do |original|
          it "should return #{answer} for #{original}" do
            expect(FactTranslator.occupancy_type(original)).to eq(answer)
          end
        end
      end
    end

    describe "NUMBER OF UNITS" do
      {
        [nil, 0] => nil, 
        [1] => 1, 
        [2] => 2, 
        [3] => 3, 
        [4] => 4
      }.each do |originals, answer|
        originals.each do |original|
          it "should return #{answer} for #{original}" do
            expect(FactTranslator.number_of_units(original)).to eq(answer)
          end
        end
      end
    end

    describe "PURPOSE OF REFINANCE" do
      {
        ["Cash-Out/Debt Consolidation", "CashOutDebtConsolidation"] => "Cash-Out/Debt Consolidation", 
        ["Cash-Out/Home Improvement", "CashOutHomeImprovement"] => "Cash-Out/Home Improvement", 
        ["Cash-Out/Other", "CashOutOther"] => "Cash-Out/Other", 
        ["Limited Cash-Out", "CashOutLimited"] => "Limited Cash-Out", 
        ["No Cash-Out Rate/Term", "NoCashOutStreamlinedRefinance", "ChangeInRateTerm", "NoCashOutFHAStreamlinedRefinance", "VAStreamlinedRefinance"] => "No Cash-Out Rate/Term"
      }.each do |originals, answer|
        originals.each do |original|
          it "should return #{answer} for #{original}" do
            expect(FactTranslator.purpose_of_refinance(original)).to eq(answer)
          end
        end
      end
    end
  end
end
