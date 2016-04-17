require 'spec_helper'

describe Smds::DeliveryModelMethods do
  let(:fnmaloan) { Smds::FnmaLoan.new }
  let(:fhlbloan) { Smds::FhlbLoan.new }

  describe "BedroomCount" do
    context "For Fnma loan" do
      it "should return '' when the NbrOfBedroomUnit is nil" do
        fnmaloan.stub NbrOfBedroomUnit1: nil
        expect(fnmaloan.BedroomCount(1)).to eq ""
      end
      [[1, 1, 'Investor', 1],
      [2, 1, 'Investor', 2],
      [3, 2, 'Investor', 2],
      [4, 2, 'Investor', 1]
      ].each do |index, nbrofBedroomUnit, propertyOccupy, nbrOfUnits|
        it "should return #{nbrofBedroomUnit} when PropertyOccupy is Investor and NbrofUnits is more than 0" do
          fnmaloan["NbrOfBedroomUnit#{index}"] = nbrofBedroomUnit
          fnmaloan.stub NbrOfUnits: nbrOfUnits
          fnmaloan.stub PropertyOccupy: propertyOccupy
          expect(fnmaloan.BedroomCount(index)).to eq nbrofBedroomUnit
        end
      end

      [
      [2, 1, 'PrimaryOccupy', 2],
      [3, 2, 'PrimaryOccupy', 2],
      ].each do |index, nbrofBedroomUnit, propertyOccupy, nbrOfUnits|
        it "should return BedroomCount#{index} as #{nbrofBedroomUnit} when PropertyOccupy is not Investor and NbrofUnits is more than 1" do
          fnmaloan["NbrOfBedroomUnit#{index}"] = nbrofBedroomUnit
          fnmaloan.stub NbrOfUnits: nbrOfUnits
          fnmaloan.stub PropertyOccupy: propertyOccupy
          expect(fnmaloan.BedroomCount(index)).to eq nbrofBedroomUnit
        end
      end

      [[1, 1, 'PrimaryOccupy', 1],
      [4, 2, 'PrimaryOccupy', 1]
      ].each do |index, nbrofBedroomUnit, propertyOccupy, nbrOfUnits|
        it "should return BedroomCount#{index} as '' when PropertyOccupy is not Investor and NbrofUnits is not more than 1" do
          fnmaloan["NbrOfBedroomUnit#{index}"] = nbrofBedroomUnit
          fnmaloan.stub NbrOfUnits: nbrOfUnits
          fnmaloan.stub PropertyOccupy: propertyOccupy
          expect(fnmaloan.BedroomCount(index)).to eq ''
        end
      end
    end

    context "FHLB loans" do
      it "should return '' when the NbrOfBedroomUnit is nil" do
        fhlbloan.stub NbrOfBedroomUnit1: nil
        expect(fhlbloan.BedroomCount(1)).to eq ""
      end

      [[1, 1, 'Investor', 1],
      [2, 1, 'Investor', 2],
      [3, 2, 'Investor', 2],
      [4, 2, 'Investor', 1]
      ].each do |index, nbrofBedroomUnit, propertyOccupy, nbrOfUnits|
        it "should return #{nbrofBedroomUnit} when PropertyOccupy is Investor and NbrofUnits is more than 0" do
          fhlbloan["NbrOfBedroomUnit#{index}"] = nbrofBedroomUnit
          fhlbloan.stub NbrOfUnits: nbrOfUnits
          fhlbloan.stub PropertyOccupy: propertyOccupy
          expect(fhlbloan.BedroomCount(index)).to eq nbrofBedroomUnit
        end
      end
    end
  end

  describe "isInvestor" do
    it "should return true when PropertyOccupy is Investor and NbrOfUnits is more than 0" do
      fnmaloan.stub PropertyOccupy: 'Investor'
      fnmaloan.stub NbrOfUnits: 1
      expect(fnmaloan.isInvestor).to eq true
    end

    it "should return false when PropertyOccupy is not Investor or NbrOfUnits is 0" do
      fnmaloan.stub PropertyOccupy: 'Attached'
      fnmaloan.stub NbrOfUnits: 1
      expect(fnmaloan.isInvestor).to eq false

      fhlbloan.stub PropertyOccupy: 'Investor'
      fhlbloan.stub NbrOfUnits: 0
      expect(fhlbloan.isInvestor).to eq false
    end
  end

  describe "notInvestor" do
    it "should return true when PropertyOccupy is not Investor and NbrOfUnits is more than 1" do
      fhlbloan.stub PropertyOccupy: 'Attached'
      fhlbloan.stub NbrOfUnits: 2
      expect(fhlbloan.notInvestor).to eq true
    end

    it "should return false when PropertyOccupy is Investor or NbrOfUnits is not greater than 1" do
      fnmaloan.stub PropertyOccupy: 'Investor'
      fnmaloan.stub NbrOfUnits: 2
      expect(fnmaloan.notInvestor).to eq false

      fhlbloan.stub PropertyOccupy: 'Attached'
      fhlbloan.stub NbrOfUnits: 1
      expect(fhlbloan.notInvestor).to eq false  
    end
  end

  describe "PropertyDwellingUnitEligibleRentAmount" do
    it "should return '' when EligibleRentUnit is null" do
      fnmaloan.stub NbrOfUnits: 1
      fnmaloan.stub EligibleRentUnit1: nil
      expect(fnmaloan.PropertyDwellingUnitEligibleRentAmount(1)).to eq ''
    end

    (1..4).each do |n|
      [['Investor', 1, 600.00, 600],
      ['Investor',0, 400.00, ''],
      ['Attached', 2, 500.00, 500],
      ['Attached', 1, 400.00, ''],
      ['Investor', 2, 0.0, '']
    ].each do |property_occupy, number_of_units, eligible_rent_unit, property_dwelling_unit|
      it "should return PropertyDwellingUnitEligibleRentAmount#{n} as #{property_dwelling_unit} when PropertyOccupy is #{property_occupy}, NbrOfUnits is #{number_of_units} and EligibleRentUnit#{n} is #{eligible_rent_unit}" do
        fnmaloan.stub PropertyOccupy: property_occupy
        fnmaloan.stub NbrOfUnits: number_of_units
        fnmaloan["EligibleRentUnit#{n}"] = eligible_rent_unit
        expect(fnmaloan.PropertyDwellingUnitEligibleRentAmount(n)).to eq property_dwelling_unit
      end
    end
    end
  end

  describe "ConvertibleIndicator" do
    it "should return true when ARMConvertibility is Y" do
      fnmaloan.stub ARMConvertibility: "Y"
      expect(fnmaloan.ConvertibleIndicator).to eq true
    end
    it "should return false when ARMConvertibility is not Y" do
      fhlbloan.stub ARMConvertibility: "N"
      expect(fhlbloan.ConvertibleIndicator).to eq false
    end
  end

  describe "EscrowIndicator" do
    it "should return false when EscrowWaiverFlg is Y" do
      fnmaloan.stub EscrowWaiverFlg: "Y"
      expect(fnmaloan.EscrowIndicator).to eq false
    end
    it "should return true when EscrowWaiverFlg is N" do
      fhlbloan.stub EscrowWaiverFlg: "N"
      expect(fhlbloan.EscrowIndicator).to eq true
    end
  end

  describe "InterestOnlyIndicator" do
    it "should return true when InterestOnlyFlg is Y" do
      fnmaloan.stub InterestOnlyFlg: "Y"
      expect(fnmaloan.InterestOnlyIndicator).to eq true
    end
    it "should return false when InterestOnlyFlg is N" do
      fhlbloan.stub InterestOnlyFlg: "N"
      expect(fhlbloan.InterestOnlyIndicator).to eq false
    end
  end

  describe "LoanAffordableIndicator" do
    it "should return true when AffordableLoanFlag is Y" do
      fnmaloan.stub AffordableLoanFlag: "Y"
      expect(fnmaloan.LoanAffordableIndicator).to eq true
    end
    it "should return false when AffordableLoanFlag is N" do
      fhlbloan.stub AffordableLoanFlag: "N"
      expect(fhlbloan.LoanAffordableIndicator).to eq false
    end
  end

  describe "PrepaymentPenaltyIndicator" do
    it "should return true when PrepayPenaltyFlg is Y" do
      fnmaloan.stub PrepayPenaltyFlg: "Y"
      expect(fnmaloan.PrepaymentPenaltyIndicator).to eq true
    end
    it "shoudl return false when PrepayPenaltyFlg is N" do
      fhlbloan.stub PrepayPenaltyFlg: "N"
      expect(fhlbloan.PrepaymentPenaltyIndicator).to eq false
    end
  end

  describe "RelocationLoanIndicator" do
    it "should return true when RelocationLoanFlag is Y" do
      fnmaloan.stub RelocationLoanFlag: "Y"
      expect(fnmaloan.RelocationLoanIndicator).to eq true
    end
    it "should return false when RelocationLoanFlag is N" do
      fhlbloan.stub RelocationLoanFlag: "N"
      expect(fhlbloan.RelocationLoanIndicator).to eq false
    end
  end

  describe "SharedEquityIndicator" do
    it "should return true when SharedEquityFlag is Y" do
      fnmaloan.stub SharedEquityFlag: "Y"
      expect(fnmaloan.SharedEquityIndicator).to eq true
    end
    it "should return false when SharedEquityFlag is N" do
      fhlbloan.stub SharedEquityFlag: "N"
      expect(fhlbloan.SharedEquityIndicator).to eq false
    end
  end

  describe "AutomatedUnderwritingSystemType" do
    [['DU', 'DesktopUnderwriter'],
    ['LP', 'Other'],
    ['anything', '']
    ].each do |aus_type, system_type|
      it "should return #{system_type} when AUSType is #{aus_type}" do
        fnmaloan.stub AUSType: aus_type
        expect(fnmaloan.AutomatedUnderwritingSystemType).to eq system_type

        fhlbloan.stub AUSType: aus_type
        expect(fhlbloan.AutomatedUnderwritingSystemType).to eq system_type
      end
    end
  end

  describe "AutomatedUnderwritingSystemTypeOtherDescription" do
    [['LP', 'LoanProspector'],
    ['anything', '']
    ].each do |aus_type, system_type_other|
      it "should return #{system_type_other} when AUSType is #{aus_type}" do
        fnmaloan.stub AUSType: aus_type
        expect(fnmaloan.AutomatedUnderwritingSystemTypeOtherDescription).to eq system_type_other

        fhlbloan.stub AUSType: aus_type
        expect(fhlbloan.AutomatedUnderwritingSystemTypeOtherDescription).to eq system_type_other
      end
    end
  end

  describe "LoanManualUnderwritingIndicator" do
    [['LP', false],
    ['DU', false],
    ['anything', true]
    ].each do |aus_type, underwriting_ind| 
      it "should return #{underwriting_ind} when AUSType is #{aus_type}" do
        fnmaloan.stub AUSType: aus_type
        expect(fnmaloan.LoanManualUnderwritingIndicator).to eq underwriting_ind

        fhlbloan.stub AUSType: aus_type
        expect(fhlbloan.LoanManualUnderwritingIndicator).to eq underwriting_ind
      end
    end
  end

  describe "AutomatedUnderwritingRecommendationDescription" do
    [['Approve/Eligible', 'ApproveEligible'],
    ['Approve/Ineligible', 'ApproveIneligible'],
    ['EA-I/Eligible', 'EAIEligible'],
    ['EA-II/Eligible', 'EAIIEligible'],
    ['EA-III/Eligible', 'EAIIIEligible'],
    ['EA-I/Ineligible', 'EAIIneligible'],
    ['EA-II/Ineligible', 'EAIIIneligible'],
    ['EA-III/Ineligible', 'EAIIIIneligible'],
    ['Refer/Eligible', 'ReferEligible'],
    ['Refer/Ineligible', 'ReferIneligible'],
    ['Refer W Caution/IV', 'ReferWithCautionIV'],
    ['Submit/Error', 'Error'],
    ['Out of Scope', 'OutofScope'],
    ['anything', 'Unknown']
    ].each do |aus_recommendaton, underwritin_recommendation|
      it " should return #{underwritin_recommendation} when AUSType is DU and AUSRecommendation is #{aus_recommendaton}" do
        fnmaloan.stub AUSType: "DU"
        fnmaloan.stub AUSRecommendation: aus_recommendaton
        expect(fnmaloan.AutomatedUnderwritingRecommendationDescription).to eq underwritin_recommendation

        fhlbloan.stub AUSType: "DU"
        fhlbloan.stub AUSRecommendation: aus_recommendaton
        expect(fhlbloan.AutomatedUnderwritingRecommendationDescription).to eq underwritin_recommendation
      end
    end

    it "should return '' when AUSRecommendation is NA" do
      fnmaloan.stub AUSRecommendation: "NA"
      fnmaloan.stub AUSType: "DU"
      expect(fnmaloan.AutomatedUnderwritingRecommendationDescription).to eq ''
    end

    it "should return '' when AUSType is not DU" do
      fhlbloan.stub AUSType: "LP"
      expect(fhlbloan.AutomatedUnderwritingRecommendationDescription).to eq ''
    end
  end

  describe "AutomatedUnderwritingCaseIdentifier" do
    it "should return value in AUSKey when AUSType is DU" do
      fnmaloan.stub AUSType: "DU"
      fnmaloan.stub AUSKey: "1225776653"
      expect(fnmaloan.AutomatedUnderwritingCaseIdentifier).to eq "1225776653"
    end
    it "should return '' when AUSType is not DU" do
      fhlbloan.stub AUSType: "LP"
      fnmaloan.stub AUSKey: "12"
      expect(fhlbloan.AutomatedUnderwritingCaseIdentifier).to eq ''
    end

    it "should return '' when AUSKey is NA" do
      fnmaloan.stub AUSKey: "NA"
      fnmaloan.stub AUSType: "DU"
      expect(fnmaloan.AutomatedUnderwritingCaseIdentifier).to eq ''
    end
  end

  describe "InvestorFeatureIdentifier1..6" do
    context "when CntSFC is 5" do
      [[1, "007"],
      [2, "180"],
      [3, "211"],
      [4, "221"],
      [5, "943"],
      [6, '']
      ].each do |index_count, investor_feature_identifier|
        it "should return #{investor_feature_identifier} when invoked InvestorFeatureIdentifier(#{index_count})" do
          fnmaloan.stub StringSFC: "007180211221943"
          fnmaloan.stub CntSFC: 5
          expect(fnmaloan.InvestorFeatureIdentifier(index_count)).to eq investor_feature_identifier
        end
      end
    end

    context "when invoked InvestorFeatureIdentifier(6)" do
      before do
        fhlbloan.stub StringSFC: "007180211221943"
      end

      it "should return '150' when NbrFinancedProperties is > 4" do
        fhlbloan.stub CntSFC: 5
        fhlbloan.stub NbrFinancedProperties: 5
        expect(fhlbloan.InvestorFeatureIdentifier(6)).to eq '150'
      end

      it "should return '' when NbrFinancedProperties is < 4 and CntSFC is 5" do
        fhlbloan.stub CntSFC: 5
        expect(fhlbloan.InvestorFeatureIdentifier(6)).to eq ''
      end

      it "should return '345' when CntSFC is 6 " do
        fnmaloan.stub NbrFinancedProperties: 5
        fnmaloan.stub CntSFC: 6
        fnmaloan.stub StringSFC: "007180211221943345"
        expect(fnmaloan.InvestorFeatureIdentifier(6)).to eq '345'
      end
    end

    describe 'LoanPurposeType' do
      [['Purchase', 'Purchase'],
       ['Refinance', 'Refinance'],
       ['anything_else', '']].each do |loan_purpose, purpose_type|
        it "should return #{purpose_type} when LnPurpose is #{loan_purpose}" do
          fnmaloan.stub LnPurpose: loan_purpose
          expect(fnmaloan.LoanPurposeType).to eq purpose_type
        end
      end
    end

    describe 'LienPriorityType1' do
      [['FirstLien', 'FirstLien'],
      ['SecondLien', 'SecondLien'],
      ['something', '']
      ].each do |lien_priority, type|
        it "should return #{type} when LienPriority is #{lien_priority}" do
          fnmaloan.stub LienPriority: lien_priority
          expect(fnmaloan.LienPriorityType1).to eq type

          fhlbloan.stub LienPriority: lien_priority
          expect(fhlbloan.LienPriorityType1).to eq type
        end
      end
    end

    describe "PropertyEstateType" do
      [['FeeSimple', 'FeeSimple'],
      ['Leasehold', 'Leasehold'],
      ['something', '']
      ].each do |title_right, property_estate_type|
        it "should return #{property_estate_type} when TitleRights is #{title_right}" do
          fnmaloan.stub TitleRights: title_right
          expect(fnmaloan.PropertyEstateType).to eq property_estate_type

          fhlbloan.stub TitleRights: title_right
          expect(fhlbloan.PropertyEstateType).to eq property_estate_type
        end
      end
    end

    describe "PropertyFloodInsuranceIndicator" do
      it "should return true when SpecialFloodHazardArea is Y" do
        fnmaloan.stub SpecialFloodHazardArea: "Y"
        expect(fnmaloan.PropertyFloodInsuranceIndicator).to eq true

        fhlbloan.stub SpecialFloodHazardArea: "Y"
        expect(fhlbloan.PropertyFloodInsuranceIndicator).to eq true
      end
      it "should return false when SpecialFloodHazardArea is not Y" do
        fnmaloan.stub SpecialFloodHazardArea: "N"
        expect(fnmaloan.PropertyFloodInsuranceIndicator).to eq false
      end
    end

    describe "PUDIndicator" do
      [['CONDOPUD', true],
      ['pudindicator', true],
      ['Pud', true],
      ['indicator', false]
      ].each do |pud_ind, indicator|
        it "should return #{indicator} when ProjectName id #{pud_ind}" do
          fnmaloan.stub PropertyType: pud_ind
          expect(fnmaloan.PUDIndicator).to eq indicator

          fhlbloan.stub PropertyType: pud_ind
          expect(fhlbloan.PUDIndicator).to eq indicator
        end
      end
    end

    describe "ConstructionMethodType" do
      [['Modular', 'Modular'],
      ['Manufactured', 'Manufactured'],
      ['SiteBuilt', 'SiteBuilt'],
      ['something', '']
      ].each do |construction_type, type_method|
        it "should return #{type_method} when ConstructionType is #{construction_type}" do
          fnmaloan.stub ConstructionType: construction_type
          expect(fnmaloan.ConstructionMethodType).to eq type_method
        end
      end
    end

    describe "PropertyUsageType" do
      [['PrimaryResidence', 'PrimaryResidence'],
      ['SecondHome', 'SecondHome'],
      ['Investor', 'Investment'],
      ['something', '']
      ].each do |property_occupy, usage_type|
        it "should return #{usage_type} when PropertyOccupy is #{property_occupy}" do
          fnmaloan.stub PropertyOccupy: property_occupy
          expect(fnmaloan.PropertyUsageType).to eq usage_type

          fhlbloan.stub PropertyOccupy: property_occupy
          expect(fhlbloan.PropertyUsageType).to eq usage_type
        end
      end
    end

    describe "FinancedUnitCount" do
      it "should return '5' when the NbrOfUnits is 5" do
        fnmaloan.stub NbrOfUnits: 5
        expect(fnmaloan.FinancedUnitCount).to eq '5'
      end

      it "should return '' when the NbrOfUnits is 0" do
        fnmaloan.stub NbrOfUnits: 0
        expect(fnmaloan.FinancedUnitCount).to eq ''
      end

      it "should return '' when the NbrOfUnits is nil" do
        fhlbloan.stub NbrOfUnits: nil
        expect(fhlbloan.FinancedUnitCount).to eq ''
      end
    end

    describe "PropertyStructureBuiltYear" do
      it "should return '1945' when YearBuilt is 1945" do
        fnmaloan.stub YearBuilt: 1945
        expect(fnmaloan.PropertyStructureBuiltYear).to eq '1945'
      end
      it "should return '' when YearBuilt is NA" do
        fhlbloan.stub YearBuilt: 'NA'
        expect(fhlbloan.PropertyStructureBuiltYear).to eq ''
      end
      it "should return '' when the YearBuilt is nil" do
        fnmaloan.stub YearBuilt: nil
        expect(fnmaloan.PropertyStructureBuiltYear).to eq ''
      end
    end

    describe "ProjectLegalStructureType" do
      [['PCONDOMINIUM', 'Condominium'],
      ['RCondominium', 'Condominium'],
      ['Tcondo', 'Condominium'],
      ['anything', '']
      ].each do |property_type, structure_type|
        it "should return #{structure_type} when PropertyType is #{property_type}" do
          fnmaloan.stub PropertyType: property_type
          expect(fnmaloan.ProjectLegalStructureType).to eq structure_type

          fhlbloan.stub PropertyType: property_type
          expect(fhlbloan.ProjectLegalStructureType).to eq structure_type
        end
      end
    end

    describe "SpecialFloodHazardAreaIndicator" do
      it "should return true when SpecialFloodHazardArea is Y" do
        fnmaloan.stub SpecialFloodHazardArea: "Y"
        expect(fnmaloan.SpecialFloodHazardAreaIndicator).to eq true
      end

      it "should return false when SpecialFloodHazardArea is N" do
        fhlbloan.stub SpecialFloodHazardArea: "N"
        expect(fhlbloan.SpecialFloodHazardAreaIndicator).to eq false
      end
    end

    describe "LoanAmortizationType" do
      [['Fixed', 'Fixed'],
      ['AdjustableRate', 'AdjustableRate'],
      ['Anything', '']
      ].each do |ln_amort_type, amortization_type|
        it "should return #{amortization_type} when LnAmortType is #{ln_amort_type}" do
          fnmaloan.stub LnAmortType: ln_amort_type
          expect(fnmaloan.LoanAmortizationType).to eq amortization_type

          fhlbloan.stub LnAmortType: ln_amort_type
          expect(fhlbloan.LoanAmortizationType).to eq amortization_type
        end
      end
    end

    describe "BalloonIndicator" do
      it "should return true when BalloonFlg is Y" do
        fnmaloan.stub BalloonFlg: "Y"
        expect(fnmaloan.BalloonIndicator).to eq true

        fhlbloan.stub BalloonFlg: "Y"
        expect(fhlbloan.BalloonIndicator).to eq true
      end

      it "should return false when BalloonFlg is N" do
        fnmaloan.stub BalloonFlg: "N"
        expect(fnmaloan.BalloonIndicator).to eq false

        fhlbloan.stub BalloonFlg: ""
        expect(fhlbloan.BalloonIndicator).to eq false
      end
    end

    describe "BorrowerCount" do
      it "should return '' when NbrOfBrw is 0" do
        fnmaloan.stub NbrOfBrw: 0
        expect(fnmaloan.BorrowerCount).to eq ''

        fhlbloan.stub NbrOfBrw: 0
        expect(fhlbloan.BorrowerCount).to eq ''
      end

      it "should return the NbrOfBrw when > 0" do
        fnmaloan.stub NbrOfBrw: 1
        expect(fnmaloan.BorrowerCount).to eq '1'

        fhlbloan.stub NbrOfBrw: 5
        expect(fhlbloan.BorrowerCount).to eq '5'
      end
    end

    describe "BuydownTemporarySubsidyIndicator" do
      it "should return true when the BuydownFlg is Y" do
        fnmaloan.stub BuydownFlg: "Y"
        expect(fnmaloan.BuydownTemporarySubsidyIndicator).to eq true
      end

      it "shoudl return false when the BuydownFlg is N" do
        fhlbloan.stub BuydownFlg: "N"
        expect(fhlbloan.BuydownTemporarySubsidyIndicator).to eq false

        fnmaloan.stub BuydownFlg: "N"
        expect(fnmaloan.BuydownTemporarySubsidyIndicator).to eq false
      end
    end

    describe "InvestorCollateralProgramIdentifier" do
      it "should return '' when the PropertyValMethod is not None" do
        fnmaloan.stub PropertyValMethod: 'something'
        expect(fnmaloan.InvestorCollateralProgramIdentifier).to eq ''
      end

      it "should return the value within InvestorCollateralPrgm when PropertyValMethod is None" do
        fnmaloan.stub PropertyValMethod: 'None'
        fnmaloan.stub InvestorCollateralPrgm: 'DURefiPlusPropertyFieldworkWaiver'

        expect(fnmaloan.InvestorCollateralProgramIdentifier).to eq 'DURefiPlusPropertyFieldworkWaiver'

        fhlbloan.stub PropertyValMethod: 'None'
        fhlbloan.stub InvestorCollateralPrgm: 'somethingElse'

        expect(fhlbloan.InvestorCollateralProgramIdentifier).to eq 'somethingElse'
      end
    end
  end
end