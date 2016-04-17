require 'spec_helper'

describe Smds::FnmaLoan do
  it { should be_a Smds::FnmaLoan }
  its(:guarantee_fee_percent) { should be_nil }

  describe "#LoanLevelCreditScore" do
    before { 
      subject.stub borrowers: [] 
      subject.stub RepresentativeFICO: 781
    }

    it "should pick the smaller of the primary and co-borrowers' credit scores" do
      make_borrower 1, '1'
      make_borrower 2, '2'
      subject.LoanLevelCreditScore.should == 781
    end

    it "should use numerical comparison to pick the smallest credit score" do
      make_borrower 1, '12'
      make_borrower 2, '10'
      make_borrower 3, '7'
      subject.LoanLevelCreditScore.should == 781
    end

    ['', nil].each do |value|
      it "should pick the primary if the coborrower's score is #{value}" do
        make_borrower 1, '1'
        make_borrower 2, value
        subject.LoanLevelCreditScore.should == 781
      end
    end

    def make_borrower(index, score)
      b = Smds::UlddBorrower.new(subject, index)
      b.stub credit_score: score
      subject.borrowers << b
    end
  end

  describe "CondominiumProjectStatusType" do
    context "When the loan is Condominium" do
      before { subject.stub  PropertyType: 'Condominium'}
      [ ['New', 'New'],
        ['Established', 'Established'],
        ['NA',''],
        ['something', '']
      ].each do |status_type, expected|
        it "should return #{expected} when CondoProjStatusType is #{status_type}" do
          subject.stub CondoProjStatusType: status_type
          expect( subject.CondominiumProjectStatusType ).to eq expected
        end
      end
    end
    context "When loan is not a Condo return ''" do
      [['PUD', ''],
      ['Detached', ''],
      ['Attached', '']
      ].each do |property_type, expected| 
        it "should return '' when ProjectType is not condominium" do
          subject.stub PropertyType: property_type
          expect(subject.CondominiumProjectStatusType).to eq expected
        end
      end
    end
  end

  describe "LoanDefaultLossPartyType" do
    before { subject.stub InvestorName: "Fannie Mae - MBS" }
    it "should return '' when the InvestorCommitNbr is different" do
      subject.stub InvestorCommitNbr: "FN123456"
      expect(subject.LoanDefaultLossPartyType).to eq ''
    end

    it "should return Investor when the InvestorCommitNbr has ME as prefix" do
      subject.stub InvestorCommitNbr: "ME5678"
      expect(subject.LoanDefaultLossPartyType).to eq 'Investor'
    end

    it "should return '' when Investor name is not Fannie Mae" do
      subject.stub InvestorName: "Fannie Mae"
      expect(subject.LoanDefaultLossPartyType).to eq ''
    end
  end

  describe "REOMarketingPartyType" do
    before { subject.stub InvestorName: "Fannie Mae - MBS" }
    it " should return '' when the InvestorCommitNbr is different" do
      subject.stub InvestorCommitNbr: "FN123456"
      expect(subject.REOMarketingPartyType).to eq ''
    end

    it "should return '' when the investor name does not match" do
      subject.stub InvestorName: "Fannie mae"
      expect(subject.REOMarketingPartyType).to eq ''
    end

    it "should return Investor when investor name and commitment number matches" do
      subject.stub InvestorCommitNbr: "ME5678"
      expect(subject.REOMarketingPartyType).to eq 'Investor'
    end
  end

  describe "LoanAcquisitionScheduledUPBAmount" do
    before do
      subject.stub InvestorName: "Fannie Mae - MBS"
      subject.stub InvestorCommitNbr: "ME5678"
    end

    it "should return '' when CalcSoldScheduledBal is nil" do
      expect(subject.LoanAcquisitionScheduledUPBAmount).to eq ''
    end

    it "should return rounded CalcSoldScheduledBal" do
      subject.stub CalcSoldScheduledBal: BigDecimal.new('23.457')
      expect(subject.LoanAcquisitionScheduledUPBAmount).to eq 23.46
    end
  end

  describe "Project Detail builder attributes" do
    before do 
      subject.stub PropertyType: "Condominium"
      subject.stub CondoProjAttachType: "Attached"
      subject.stub ProjectType: "QCondominium"
    end

    describe "ProjectDesignType" do
      
      [['QCondominium', 'Midrise Project', 'Midrise Project'],
      ['VCondominium', 'NA', ''],
      ['RCondominium', 'Garden Project', 'Garden Project'],
      ['PCondominium', 'Garden Project', 'Garden Project'],
      ['SCondominium', 'NA', ''],
      ['TCondominium', 'TownHouseRowHouse', 'TownHouseRowHouse'],
      ['UCondominium', 'Garden Project', 'Garden Project'],
      ['Established', 'Garden', ''],
      ['New Project', 'TownHouseRowHouse', '']
      ].each do |project_type, condo_proj_design_type, proj_design_type|
        it "should return #{proj_design_type} when ProjectType is #{project_type}, CondoProjDesignType is #{condo_proj_design_type} and PropertyType is Condominium" do
          subject.stub ProjectType: project_type
          subject.stub CondoProjDesignType: condo_proj_design_type
          expect(subject.ProjectDesignType).to eq proj_design_type
        end
      end

      it "should return '' when PropertyType is not condo" do
        subject.stub PropertyType: "PUD"
        subject.stub ProjectType: "QCondominium"
        expect(subject.ProjectDesignType).to eq ''
      end

      it "should return '' when CondoProjAttachType is not Attached" do
        subject.stub CondoProjAttachType: "Dettached"
        expect(subject.ProjectDesignType).to eq ''
      end

      it "should return '' when CondoProjDesignType is NA" do
        subject.stub CondoProjDesignType: 'NA'
        expect(subject.ProjectDesignType).to eq ''
      end
    end

    describe "ProjectDwellingUnitCount" do
      
      [['QCondominium', '26', '26'],
      ['VCondominium', 'NA', ''],
      ['RCondominium', '50', '50'],
      ['PCondominium', '215', '215'],
      ['SCondominium', 'NA', ''],
      ['TCondominium', '23', '23'],
      ['UCondominium', '183', '183'],
      ['Established', '12', ''],
      ['New Project', '128', '']
      ].each do |project_type, condo_proj_total_units, proj_dwelling_unit|
        it "should return #{proj_dwelling_unit} when ProjectType is #{project_type}, CondoProjTotalUnits is #{condo_proj_total_units} and PropertyType is Condominium" do
          subject.stub ProjectType: project_type
          subject.stub CondoProjTotalUnits: condo_proj_total_units
          expect(subject.ProjectDwellingUnitCount).to eq proj_dwelling_unit
        end
      end

      it "should return '' when PropertyType is not condo" do
        subject.stub PropertyType: "PUD"
        subject.stub ProjectType: "QCondominium"
        expect(subject.ProjectDwellingUnitCount).to eq ''
      end

      it "should return '' when CondoProjAttachType is not Attached" do
        subject.stub CondoProjAttachType: "Dettached"
        expect(subject.ProjectDwellingUnitCount).to eq ''
      end

      it "should return '' when CondoProjTotalUnits is NA" do
        subject.stub CondoProjTotalUnits: 'NA'
        expect(subject.ProjectDwellingUnitCount).to eq ''
      end    
    end

    describe "ProjectDwellingUnitsSoldCount" do
      
      [['QCondominium', '26', '26'],
      ['VCondominium', 'NA', ''],
      ['RCondominium', '50', '50'],
      ['PCondominium', '215', '215'],
      ['SCondominium', 'NA', ''],
      ['TCondominium', '23', '23'],
      ['UCondominium', '183', '183'],
      ['Established', '12', ''],
      ['New Project', '128', '']
      ].each do |project_type, condo_proj_units_sold, proj_dwelling_sold_unit|
        it "should return #{proj_dwelling_sold_unit} when ProjectType is #{project_type}, CondoProjUnitsSold is #{condo_proj_units_sold} and PropertyType is Condominium" do
          subject.stub ProjectType: project_type
          subject.stub CondoProjUnitsSold: condo_proj_units_sold
          expect(subject.ProjectDwellingUnitsSoldCount).to eq proj_dwelling_sold_unit
        end
      end

      it "should return '' when PropertyType is not condo" do
        subject.stub PropertyType: "PUD"
        subject.stub ProjectType: "QCondominium"
        expect(subject.ProjectDwellingUnitsSoldCount).to eq ''
      end

      it "should return '' when CondoProjAttachType is not Attached" do
        subject.stub CondoProjAttachType: "Dettached"
        expect(subject.ProjectDwellingUnitsSoldCount).to eq ''
      end

      it "should return '' when CondoProjUnitsSold is NA" do
        subject.stub CondoProjUnitsSold: 'NA'
        expect(subject.ProjectDwellingUnitsSoldCount).to eq ''
      end
    end

    describe "LoanAffordableIndicator" do
      it "should return true when AffordableLoanFlag is Y" do
        subject.stub AffordableLoanFlag: "Y"
        expect(subject.LoanAffordableIndicator).to eq true
      end
      it "should return false when AffordableLoanFlag is N" do
        subject.stub AffordableLoanFlag: "N"
        expect(subject.LoanAffordableIndicator).to eq false
      end
      context "Home Ready" do
        ['C10/1ARM LIB HR','C15FXD HR','C20FXD HR','C30FXD HR','C5/1ARM LIB HR','C7/1ARM LIB HR'].each do |product_code|
          it "should return true when ProductCode for loan is #{product_code}" do
            subject.stub ProductCode: product_code
            expect(subject.LoanAffordableIndicator).to eq true
          end
        end
      end
    end
  end

  describe "BorrowerPaidDiscountPointsTotalAmount" do
    it "should come from BorrowerPdDiscPtsTotalAmt" do
      subject.stub BorrowerPdDiscPtsTotalAmt: 123
      expect(subject.BorrowerPaidDiscountPointsTotalAmount).to eq 123
    end

    it "should be 0 if the value is negative" do
      subject.stub BorrowerPdDiscPtsTotalAmt: -1
      expect(subject.BorrowerPaidDiscountPointsTotalAmount).to eq 0
    end

    it "should not explode for nil" do
      subject.stub BorrowerPdDiscPtsTotalAmt: nil
      expect(subject.BorrowerPaidDiscountPointsTotalAmount).to eq nil
    end
  end

  describe "TotalMortgagedPropertiesCount" do
    it "should come from NbrFinancedProperties" do
      subject.stub NbrFinancedProperties: "foo"
      expect(subject.TotalMortgagedPropertiesCount).to eq "foo"
    end
  end

  describe "BorrowerReservesMonthlyPaymentCount" do
    it "should come from NbrMonthsReserves as int" do
      subject.stub NbrMonthsReserves: 1.0
      expect(subject.BorrowerReservesMonthlyPaymentCount.to_s).to eq "1"
    end

    it "should handle nil" do
      subject.stub NbrMonthsReserves: nil
      expect(subject.BorrowerReservesMonthlyPaymentCount).to eq 0
    end

    it "should return 999 when count is greater than 999" do
      subject.stub NbrMonthsReserves: 1999
      expect(subject.BorrowerReservesMonthlyPaymentCount).to eq 999
    end
  end

  describe "RefinanceCashOutAmount" do
    it "should be nil when loan is not refi" do
      subject.stub LnPurpose: "Purchase"
      expect(subject.RefinanceCashOutAmount).to eq nil
    end

    it "should format to 2 places the CashOutAmount when refi" do
      subject.stub LnPurpose: "Refinance", CashOutAmt: "123.1"
      expect(subject.RefinanceCashOutAmount).to eq "123.10"
    end
  end

  describe "PropertyValuationFormType" do
    [
      ["Form 1004 appraisal with interior/exterior inspection", "UniformResidentialAppraisalReport"],
      ["Form 1004C, Manufactured Home Appraisal Report with interior/exterior inspection", "ManufacturedHomeAppraisalReport"],
      ["Form 1004D appraisal updated/completion report" , "AppraisalUpdateAndOrCompletionReport"],
      ["Form 1025 appraisal with interior/exterior inspection" , "SmallResidentialIncomePropertyAppraisalReport"],
      ["Form 1073 condominium appraisal with interior/exterior inspection" , "IndividualCondominiumUnitAppraisalReport"],
      ["Form 1075 condominium appraisal with exterior inspection" , "ExteriorOnlyInspectionIndividualCondominiumUnitAppraisalReport"],
      ["Form 2055 appraisal with exterior only inspection" ,"ExteriorOnlyInspectionResidentialAppraisalReport"],
      ["Form 2075 exterior inspection" , "DesktopUnderwriterPropertyInspectionReport"],
      ["Somthing else", '']
    ].each do |field_work, form_type|
      it "should return #{form_type} when FieldworkObtained is #{field_work}" do
        subject.stub FieldworkObtained: field_work
        expect(subject.PropertyValuationFormType).to eq form_type
      end
    end
  end
end
