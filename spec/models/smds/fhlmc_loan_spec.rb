require 'spec_helper'

describe Smds::FhlmcLoan do
  context 'class methods' do
    it "should be able to find" do
      # see bug CTMWEB-1344
      expect { Smds::FhlmcLoan.find('1234567') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should be able to include hud lines' do
      expect { Smds::FhlmcLoan.new.hud_lines }.not_to raise_error
    end
  end

  context 'instance methods' do
    subject(:loan) { Smds::FhlmcLoan.new }
    let(:hud_lines) { [] }
    before do
      loan.stub hud_lines: hud_lines
      loan.stub transaction_detail: TransactionDetail.new
    end

    it 'should have the correct index source type' do
      loan.index_source_type.should eql 'LIBOROneYearWSJDaily'
    end

    describe 'subordinate_loans' do
      its(:subordinate_loans) { should == [] }
    end

    shared_examples_for "an integer" do |method, source|
      it "should replace 0 with blank" do
        loan.stub source => 0
        loan.public_send(method).should be_empty
      end

      it "should replace NA with blank" do
        loan.stub source => 'NA'
        loan.public_send(method).should be_empty
      end

      it "should use the value of #{source.to_s}, rounded to zero decimals" do
        loan.stub source => 12345.79
        loan.public_send(method).should == '12346'
      end
    end

    shared_examples_for "a number with decimal places" do |method, source, decimals|
      it "should be blank when #{source} is 0" do
        loan.stub source => 0
        loan.public_send(method).should == ''
      end

      it "should round to #{decimals} decimal places" do
        x = 123.456789
        loan.stub source => x
        loan.public_send(method).should == "%.#{decimals}f" % x
      end
    end


    shared_examples_for "an enumeration" do |method, source, legal_values|
      legal_values.each do |value|
        it "should be #{value} when #{source} is #{value}" do
          loan.stub source => value
          loan.public_send(method).should == value
        end
      end

      it "should be blank for other values" do
        loan.stub source => 'NA'
        loan.public_send(method).should == ''
      end
    end

    it "pool_id should be the commit number minus the prefix" do
      loan.stub InvestorCommitNbr: 'AB123456'
      loan.pool_id.should == 'AB123456'
    end

    shared_examples_for "a string with max length" do |method, source, max_length|
      it "should replace NA and nil with blank" do
        ['NA', nil].each do |value|
          loan.stub source => value
          loan.public_send(method).should == ''
        end
      end

      it "should use up to #{max_length} chars of the #{source.to_s}" do
        loan.stub source => 'a'*max_length + '123'
        loan.public_send(method).should == 'a'*max_length
      end
    end

    [ [ :PostalCode1, :PropertyPostalCode, 9 ],
      [ :CityName1, :PropertyCity, 50 ],
      [ :AddressLineText1, :PropertyStreetAddress, 100 ],
      [ :StateCode1, :PropertyState, 2 ],
      [ :LoanMaturityPeriodCount, :LnMaturityTerm, 3 ],
      [ :SellerLoanIdentifier, :LnNbr, 30 ],
      [ :MERS_MINIdentifier, :MERS, 30 ],
      [ :LoanOriginatorIdentifier, :LnOriginatorId, 50 ],
      [ :LoanOriginationCompanyIdentifier, :LnOrigCompanyId, 50 ],
    ].each do |method, source, max_length|
      describe "##{method}" do
        it_behaves_like "a string with max length", method, source, max_length
      end
    end

    [ [ :FinancedUnitCount, :NbrOfUnits ],
      [ :PropertyValuationAmount, :AppraisdValue ],
      [ :LoanAmortizationPeriodCount, :LnAmortTerm ],
      [ :TotalLiabilitiesMonthlyPaymentAmount, :MonthlyDebtExp ],
      [ :TotalMonthlyIncomeAmount, :MonthlyIncome ],
      [ :TotalMonthlyProposedHousingExpenseAmount, :MonthlyHsingExp ],
      [ :PropertyDwellingUnitEligibleRentAmount1, :EligibleRentUnit1 ],
      [ :PropertyDwellingUnitEligibleRentAmount2, :EligibleRentUnit2 ],
      [ :PropertyDwellingUnitEligibleRentAmount3, :EligibleRentUnit3 ],
      [ :PropertyDwellingUnitEligibleRentAmount4, :EligibleRentUnit4 ],
    ].each do |method, source|
      describe method do
        it_behaves_like "an integer", method, source
      end
    end

    shared_examples_for "boolean property" do |method, source|
      it "should translate Y as true" do
        loan.stub source => 'Y'
        loan.public_send(method).should == true
      end

      it "should translate other values as false" do
        ['N', '', 'NA'].each do |value|
          loan.stub source => value
          loan.public_send(method).should == false
        end
      end
    end

    it '#BankruptcyIndicator' do
      loan.stub('Bankruptcy').and_return('N')
      loan.BankruptcyIndicator.should == 'false'
    end

    it '#LoanForeclosureOrJudgmentIndicator' do
      loan.stub('Foreclosure').and_return('N')
      loan.LoanForeclosureOrJudgmentIndicator.should == 'false'
    end

    it '#EmploymentBorrowerSelfEmployedIndicator' do
      loan.stub('SelfEmpFlg').and_return('N')
      loan.EmploymentBorrowerSelfEmployedIndicator.should == 'false'
    end

    [ [:SpecialFloodHazardAreaIndicator, :SpecialFloodHazardArea ],
      [:BalloonIndicator, :BalloonFlg ],
      [:BuydownTemporarySubsidyIndicator, :BuydownFlg ],
      [:HMDA_HOEPALoanStatusIndicator, :HOEPA ],
      [:ConvertibleIndicator, :ARMConvertibility ],
      [:InterestOnlyIndicator, :InterestOnlyFlg ],
      [:LoanAffordableIndicator, :AffordableLoanFlag ],
      [:PrepaymentPenaltyIndicator, :PrepayPenaltyFlg ],
      [:RelocationLoanIndicator, :RelocationLoanFlag ],
      [:SharedEquityIndicator, :SharedEquityFlag ],
    ].each do |method, source|
      describe "##{method}" do
        it_behaves_like "boolean property", method, source
      end
    end

    describe "#PUDIndicator" do
      before do
        loan.stub PropertyType: nil
        loan.stub FNMProjectType: nil
        loan.stub RlcPropType: nil
      end

      it "should be false when none of the property types contain PUD" do
        loan.PUDIndicator.should be false
      end

      [:PropertyType, :FNMProjectType, :RlcPropType ].each do |sym|
        it "should be true when #{sym} contains PUD" do
          ["E_PUD", "pud foo", "PUD thai"].each do |pt|
            loan.stub sym => pt
            loan.PUDIndicator.should be true
          end
        end
      end

    end

    describe "#ProjectLegalStructureType" do
      it "should be empty if the project is not a condo" do
        loan.stub PropertyType: 'whatever'
        loan.stub ProjectType: 'P'
        loan.ProjectLegalStructureType.should == ''
      end

      context "when the property is a condo" do
        before { loan.stub PropertyType: 'dlskfj Condo ldkfjs' }
        ['P','Q','R','S','T','U','V'].each do |initial|
          it "should be Condominium when the project type starts with #{initial}" do
            loan.stub ProjectType: initial + 'dlskfj Condo ldkfjs'
            loan.ProjectLegalStructureType.should == 'Condominium'
          end
        end

        it "should Condominium even if ProjectType is nil" do
          loan.stub ProjectType: nil
          loan.ProjectLegalStructureType.should == 'Condominium'
        end
      end
    end

    describe "#CondominiumProjectStatusType" do
      it "should be empty if the property is not a condo" do
        loan.stub ProjectLegalStructureType: ''
        loan.CondominiumProjectStatusType.should == ''
      end

      context "when the property is a condo" do
        before { loan.stub ProjectLegalStructureType: 'Condominium' }

        it_behaves_like "an enumeration", :CondominiumProjectStatusType,
          :CondoProjStatusType, [ 'Established', 'New' ]
      end
    end

    describe "#ProjectAttachmentType" do
      it "should be empty if the property type does not include condo in it" do
        loan.stub ProjectLegalStructureType: ''
        loan.ProjectAttachmentType.should == ''
      end

      it "should be empty if the ProjectClassificationIdentifier is ExemptFromReview" do
        loan.stub ProjectLegalStructureType: 'Condominium'
        loan.stub ProjectClassificationIdentifier: 'ExemptFromReview'
        loan.ProjectAttachmentType.should == ''
      end

      it "Should return attached when the PropertyType is Condominium or HighRiseCondominium and prj classification identifier is ExemptFromReview" do
        loan.stub ProjectClassificationIdentifier: 'FullReview'
        loan.stub ProjectLegalStructureType: 'Condominium'
        loan.stub AttachmentType: 'HighRiseCondominium'
        loan.ProjectAttachmentType.should == 'HighRiseCondominium'

        loan.stub AttachmentType: 'Condominium'
        loan.ProjectAttachmentType.should == 'Condominium'
      end

    end

    describe "#ProjectDesignType" do
      it "should be empty if the property is not a condo" do
        loan.stub ProjectLegalStructureType: ''
        loan.ProjectDesignType.should == ''
      end

      context "when the property is a condo" do
        before { loan.stub ProjectLegalStructureType: 'Condominium' }

        it "should be GardenProject when there are three stories or fewer" do
          (0..3).each do |stories|
            loan.stub NbrOfStories: stories
            loan.ProjectDesignType.should == 'GardenProject'
          end
        end

        it "should be Midrise when there are between 4 and 7 stories" do
          (4..7).each do |stories|
            loan.stub NbrOfStories: stories
            loan.ProjectDesignType.should == 'MidriseProject'
          end
        end

        it "should be HighriseProject when there are more than 7 stories" do
          loan.stub NbrOfStories: 8
          loan.ProjectDesignType.should == 'HighriseProject'
        end
      end
    end

    describe "#ProjectDwellingUnitCount" do
      it "should be empty if the property is not a condo" do
        loan.stub ProjectLegalStructureType: ''
        loan.stub CondoProjTotalUnits: 123
        loan.ProjectDwellingUnitCount.should == ''
      end

      context "when the property is a condo" do
        before { loan.stub ProjectLegalStructureType: 'Condominium' }

        it_behaves_like "an integer", :ProjectDwellingUnitCount, :CondoProjTotalUnits
      end
    end

    describe "#ProjectDwellingUnitsSoldCount" do
      it "should be empty if the property is not a condo" do
        loan.stub ProjectLegalStructureType: ''
        loan.stub CondoProjUnitsSold: 123
        loan.ProjectDwellingUnitsSoldCount.should == ''
      end

      context "when the property is a condo" do
        before { loan.stub ProjectLegalStructureType: 'Condominium' }

        it_behaves_like "an integer", :ProjectDwellingUnitsSoldCount, :CondoProjUnitsSold
      end
    end

    describe "#CondoProjectName" do
      it "should be empty if the property is not a condo" do
        loan.stub ProjectLegalStructureType: ''
        loan.stub ProjectName: "abc"
        loan.CondoProjectName.should == ''
      end

      context "when the property is a condo" do
        before { loan.stub ProjectLegalStructureType: 'Condominium' }

        it_behaves_like "a string with max length", :CondoProjectName, :ProjectName, 50
      end
    end

    ['FeeSimple', 'Leasehold'].each do |value|
      it "PropertyEstateType should be #{value} when TitleRights is #{value}" do
        loan.stub TitleRights: value
        loan.PropertyEstateType.should == value
      end
    end

    ['NA', 'foo'].each do |value|
      it "PropertyEstateType should be empty when TitleRights is #{value}" do
        loan.stub TitleRights: value
        loan.PropertyEstateType.should be_empty
      end
    end

    describe "#AttachmentType" do

      it "Should return the attachment type as is when it is not nil" do
        loan.stub AttachmentType: 'Attached'
        loan.AttachmentType.should == 'Attached'
      end

      it "should be blank when it is nil" do
        loan.stub AttachmentType: nil

        expect(loan.AttachmentType).to be_nil
      end
    end

    { 'Modular' => 'Modular',
      'Manufactured' => 'Manufactured',
      'SiteBuilt' => 'SiteBuilt',
      'NA' => 'SiteBuilt',
      '' => 'SiteBuilt',
      'dlsfjkd' => ''
    }.each do |ct, expected|
      it "ConstructionMethodType should be #{expected} when ConstructionType is #{ct}" do
        loan.stub ConstructionType: ct
        loan.ConstructionMethodType.should == expected
      end
    end

    describe "#PropertyFloodInsuranceIndicator" do
      it "should be true when SpecialFloodHazardArea is 'Y'" do
        loan.stub SpecialFloodHazardArea: 'Y'
        loan.PropertyFloodInsuranceIndicator.should be true
      end

      it "should be false otherwise" do
        loan.stub SpecialFloodHazardArea: 'dlfkjsdf'
        loan.PropertyFloodInsuranceIndicator.should be false
      end
    end

    describe "#PropertyUsageType" do
      { 'PrimaryResidence' => 'PrimaryResidence',
        'SecondHome' => 'SecondHome',
        'Investor' => 'Investment',
        'NA' => '',
        'sldkfj' => ''
      }.each do |occupy, expected|
        it "should be #{expected} when PropertyOccupy is #{occupy}" do
          loan.stub PropertyOccupy: occupy
          loan.PropertyUsageType.should == expected
        end
      end
    end

    describe "#PropertyValuationMethodType" do
      it "should come from the valuation class" do
        loan.valuation.stub valuation_type: 'foo'
        loan.PropertyValuationMethodType.should == 'foo'
      end
    end


    describe "#PropertyValuationFormType" do
      it "should come from the valuation class" do
        loan.valuation.stub valuation_form: 'monkey'
        loan.PropertyValuationFormType.should == 'monkey'
      end
    end

    describe "#PropertyValuationMethodTypeOtherDescription" do
      it "should come from the valuation class" do
        loan.valuation.stub valuation_other_description: 'monkey'
        loan.PropertyValuationMethodTypeOtherDescription.should == 'monkey'
      end
    end


    [ [:CombinedLTVRatioPercent, :CLTV],
      [:BaseLTVRatioPercent, :BaseLTV],
      [:LTVRatioPercent, :LTV],
    ].each do |method, source|
      describe "##{method}" do
        it_behaves_like "a number with decimal places", method, source, 4
      end
    end

    [ [:LoanAmortizationType, :LnAmortType, 'Fixed', 'AdjustableRate' ],
      [:LoanPurposeType, :LnPurpose, 'Purchase', 'Refinance' ],
      [:LienPriorityType1, :LienPriority, 'FirstLien', 'SecondLien'],
    ].each do |method, source, *values|
      describe "##{method}" do
        it_behaves_like "an enumeration", method, source, values
      end
    end

    shared_examples_for "a date field" do |method, source|
      it "should use blank instead of 1/1/1900" do
        loan.stub source => Date.new(1900, 1, 1)
        loan.public_send(method).should == ''
      end

      it "should format the date properly otherwise" do
        loan.stub source => Date.new(1999, 1, 15)
        loan.public_send(method).should == '1999-01-15'
      end
    end

    [ [:ApplicationReceivedDate, :LnAppRecdDt ],
      [:LoanStateDate1, :NoteDt ],
      [:LoanMaturityDate, :MaturityDt ],
      [:ScheduledFirstPaymentDate, :FirstPmtDt ],
      [:PriceLockDatetime, :RlcDate ],
      [:LastPaidInstallmentDueDate, :IntPaidThruDt ],
      [:NoteDate, :NoteDt ],
    ].each do |method, source|
      describe "##{method}" do
        it_behaves_like "a date field", method, source
      end
    end

    describe '#PropertyValuationEffectiveDate' do
      it 'should be nil when PropertyValuationMethodType is None or Other' do
        loan.AppraisalDt = '2014-04-17'
        loan.stub(:PropertyValuationMethodType) { 'None' }
        loan.PropertyValuationEffectiveDate.should be_nil
        loan.stub(:PropertyValuationMethodType) { 'Other' }
        loan.PropertyValuationEffectiveDate.should be_nil
        loan.stub(:PropertyValuationMethodType) { 'SomethingElse' }
        loan.PropertyValuationEffectiveDate.should_not be_nil
      end
    end

    describe "#ConstructionLoanIndicator" do
      ['ConstructionOnly', 'ConstructionToPermanent'].each do |value|
        it "should be true when LnPurpose is #{value}" do
          loan.stub LnPurpose: value
          loan.ConstructionLoanIndicator.should == true
        end
      end

      it "should be false for other values" do
        ['NA', 'sdlfj'].each do |value|
          loan.stub LnPurpose: value
          loan.ConstructionLoanIndicator.should == false
        end
      end
    end

    describe "#ConstructionLoanType" do
      it "should be ConstructionToPermanent if this is a construction loan" do
        loan.stub ConstructionLoanIndicator: true
        loan.ConstructionLoanType.should == 'ConstructionToPermanent'
      end

      it "should be blank for non-construction loans" do
        loan.stub ConstructionLoanIndicator: false
        loan.ConstructionLoanType.should == ''
      end
    end


    shared_examples_for "an amount with 2 decimal places" do |method, source|
      it "should be blank when PI is 0" do
        loan.stub source => 0
        loan.public_send(method).should == ''
      end

      it "should round to 2 decimal places" do
        loan.stub source => 123.456
        loan.public_send(method).should == '123.46'
      end
    end

    [ [:InitialPrincipalAndInterestPaymentAmount, :PI],
      [:NoteAmount, :LnAmt],
    ].each do |method, source|
      describe "##{method}" do
        it_behaves_like "an amount with 2 decimal places", method, source
      end
    end

    describe "#MortgageType1" do
      ['Conventional', 'FHA', 'VA'].each do |value|
        it "should pass #{value} through unchanged" do
          loan.stub LoanType: value
          loan.MortgageType1.should == value
        end
      end

      it "should translate FarmersHomeAdministration to USDARuralHousing" do
        loan.stub LoanType: 'FarmersHomeAdministration'
        loan.MortgageType1.should == 'USDARuralHousing'
      end

      it "should be blank otherwise" do
        ['NA', '', 'sldfj'].each do |value|
          loan.stub LoanType: value
          loan.MortgageType1.should == ''
        end
      end
    end

    describe "#NoteRatePercent" do
      it "should be blank for 0" do
        loan.stub FinalNoteRate: 0
        loan.NoteRatePercent.should == ''
      end

      it "should round to 4 decimal places" do
        loan.stub FinalNoteRate: 12.34567
        loan.NoteRatePercent.should == '12.3457'
      end
    end

    describe "#AppraiserLicenseIdentifier" do
      it "should be blank when appraiser is NA" do
        loan.stub LoanType: 'Conventional'
        loan.stub PropertyValMethod: "FullAppraisal"
        loan.stub AppraiserLicenseNbr: 'NA'
        loan.AppraiserLicenseIdentifier.should == ''
      end

      context "when appraiser is present" do
        before do 
          loan.stub AppraiserLicenseNbr: 'waffles' 
          loan.stub LoanType: 'Conventional'
        end

        ['DriveBy', 'FullAppraisal', 'PriorAppraisalUsed' ].each do |appraisal_type|
          context "when appraisal type is #{appraisal_type}" do
            it "should use the appraiser license number" do
              loan.stub PropertyValMethod: appraisal_type
              loan.AppraiserLicenseIdentifier.should == 'waffles'
            end
          end
        end

        ['NA', 'Something else'].each do |appraisal_type|
          context "when appraisal type is #{appraisal_type}" do
            it "should be blank" do
              loan.stub PropertyValMethod: appraisal_type
              loan.AppraiserLicenseIdentifier.should == ''
            end
          end
        end
      end
    end

    describe "#AppraiserSupervisorLicenseIdentifier" do
      it "should be blank when appraiser is NA" do
        loan.stub LoanType: 'Conventional'
        loan.stub PropertyValMethod: "FullAppraisal"
        loan.stub SuperAppraiserLicenceNbr: 'NA'
        loan.AppraiserSupervisorLicenseIdentifier.should == ''
      end

      context "when appraiser is present" do
        before { loan.stub SuperAppraiserLicenceNbr: 'waffles' }

        ['DriveBy', 'FullAppraisal', 'PriorAppraisalUsed' ].each do |appraisal_type|
          context "when appraisal type is #{appraisal_type}" do
            it "should use the appraiser license number" do
              loan.stub LoanType: 'Conventional'
              loan.stub PropertyValMethod: appraisal_type
              loan.AppraiserSupervisorLicenseIdentifier.should == 'waffles'
            end
          end
        end

        ['NA', 'Something else'].each do |appraisal_type|
          context "when appraisal type is #{appraisal_type}" do
            it "should be blank" do
              loan.stub PropertyValMethod: appraisal_type
              loan.AppraiserSupervisorLicenseIdentifier.should == ''
            end
          end
        end
      end
    end

    describe "#LoanOriginatorType" do
      it "should be Broker for W0" do
        loan.stub LendingChannel: 'W0 slfjk'
        loan.LoanOriginatorType.should == 'Broker'
      end
      it "should be Lender for A0" do
        loan.stub LendingChannel: 'A0-sldfjdf'
        loan.LoanOriginatorType.should == 'Lender'
      end
      it "should be Correspondent for R0" do
        loan.stub LendingChannel: 'R0lsdfkj'
        loan.LoanOriginatorType.should == 'Correspondent'
      end

      it "should be blank otherwise" do
        ['NA', '', 'asldkjW0fdklj'].each do |value|
          loan.stub LendingChannel: value
          loan.LoanOriginatorType.should == ''
        end
      end
    end

    describe "#LoanLevelCreditScore" do
      before { 
        loan.stub borrowers: [] 
        loan.stub RepresentativeFICO: 781
      }

      it "should pick the smaller of the primary and co-borrowers' credit scores" do
        make_borrower 1, '1'
        make_borrower 2, '2'
        loan.LoanLevelCreditScore.should == 781
      end

      it "should use numerical comparison to pick the smallest credit score" do
        make_borrower 1, '12'
        make_borrower 2, '10'
        make_borrower 3, '7'
        loan.LoanLevelCreditScore.should == 781
      end

      ['', nil].each do |value|
        it "should pick the primary if the coborrower's score is #{value}" do
          make_borrower 1, '1'
          make_borrower 2, value
          loan.LoanLevelCreditScore.should == 781
        end

        it "should send blank when AUSType is LP" do
          loan.stub(:AUSType) {'LP'}
          expect(loan.LoanLevelCreditScore).to eq('')
        end
      end

      def make_borrower(index, score)
        b = Smds::UlddBorrower.new(loan, index)
        b.stub credit_score: score
        loan.borrowers << b
      end
    end

    it '#LoanLevelCreditScoreSelectionMethodType' do
      loan.stub(:LoanLevelCreditScore) { nil }
      loan.LoanLevelCreditScoreSelectionMethodType.should eq('')
      loan.stub(:LoanLevelCreditScore) { 700 }
      loan.LoanLevelCreditScoreSelectionMethodType.should == 'MiddleOrLowerThenLowest'
    end

    [ [:BedroomCount1, :NbrOfBedroomUnit1],
      [:BedroomCount2, :NbrOfBedroomUnit2],
      [:BedroomCount3, :NbrOfBedroomUnit3],
      [:BedroomCount4, :NbrOfBedroomUnit4],
    ].each do |method, source|
      describe "##{method}" do
        let(:result) { loan.public_send(method) }
        before do
          loan.stub PropertyOccupy: 'slfj'
          loan.stub NbrOfUnits: 1
        end

        it "should be empty when there is only one unit and it is not an investment" do
          result.should == ''
        end

        it "should be empty when #{source} is null" do
          loan.stub NbrOfUnits: 2
          loan.stub source => nil
          result.should == ''
        end

        it "should allow zeroes" do
          loan.stub NbrOfUnits: 2
          loan.stub source => 0
          result.should == '0'
        end

        it "should have a value when there is more than one unit" do
          loan.stub NbrOfUnits: 3
          loan.stub source => 8
          result.should == '8'
        end

        it "should have a value when the property is an investment" do
          loan.stub PropertyOccupy: 'Investor'
          loan.stub source => 8
          result.should == '8'
        end
      end
    end

    describe "#AVMModelNameType" do
      it "should come from the valuation object" do
        loan.valuation.stub avm_model: 'slfkj'
        loan.AVMModelNameType.should == 'slfkj'
      end
    end

    describe "#AppraisalIdentifier" do
      it "should be empty when AppraisalDocID is NA and AppraisalIdent is missing" do
        loan.stub PropertyValMethod: 'FullAppraisal'
        loan.stub AppraisalDocID: 'NA'
        loan.stub AppraisalIdent: nil
        loan.AppraisalIdentifier.should == ''
      end

      it "should be empty if the property valuation method is something else" do
        loan.stub PropertyValMethod: 'dlfjsdf'
        loan.stub AppraisalIdent: '123'
        loan.AppraisalIdentifier.should == ''
      end

      [ 'FullAppraisal', 'DriveBy', 'PriorAppraisalUsed' ].each do |appraisal_type|
        it "should have a value when the property valuation method is #{appraisal_type}" do
          loan.stub PropertyValMethod: appraisal_type
          loan.stub AppraisalIdent: '123'
          loan.AppraisalIdentifier.should == '123'
        end
      end

      it "should not have more than 10 chars" do
        loan.stub PropertyValMethod: 'FullAppraisal'
        loan.stub AppraisalIdent: '12345678901'
        loan.AppraisalIdentifier.should == '1234567890'
      end

      it "should use the AppraisalDocID if AppraisalIdent is missing" do
        [nil, ''].each do |value|
          loan.stub PropertyValMethod: 'FullAppraisal'
          loan.stub AppraisalIdent: value
          loan.stub AppraisalDocID: '12345678901'
          loan.AppraisalIdentifier.should == '1234567890'
        end
      end
    end

    describe "#HomeEquityCombinedLTVRatioPercent" do
      #    We think that HCLTV is only for loans with related loans right now, which we're not currently
      #    dealing with.  So just hardcoding it to blank until/unless we need to deal with related loans.

  #    it "should use CLTV instead when CLTV is greater" do
  #      loan.stub HCLTV: 101
  #      loan.HomeEquityCombinedLTVRatioPercent.should == '102.0000'
  #    end
  #
  #    it_behaves_like "a number with decimal places", :HomeEquityCombinedLTVRatioPercent, :HCLTV, 4
    end

    describe "#PurchasePriceAmount" do
      before do
        loan.stub LnPurpose: 'Purchase'
        loan.stub LienPriority: 'FirstLien'
        loan.stub SalePrice: 999
      end

      it "should be empty when the loan is not for purchase" do
        loan.stub LnPurpose: 'Refi'
        loan.PurchasePriceAmount.should == ''
      end

      it "should be empty when the lien is not first" do
        loan.stub LienPriority: 'lsdkfjs'
        loan.PurchasePriceAmount.should == ''
      end

      it_behaves_like "an integer", :PurchasePriceAmount, :SalePrice
    end

    describe "#SectionOfActType" do
      before { loan.stub FHASectionAct: 'ignore this field' }

      it "should be 234c for FHA condos" do
        loan.stub MortgageType1: 'FHA'
        loan.stub ProjectLegalStructureType: 'Condominium'
        loan.SectionOfActType.should == '234c'
      end

      it "should be 203b for FHA non-condos" do
        loan.stub MortgageType1: 'FHA'
        loan.stub ProjectLegalStructureType: 'sldkfjsdflkj'
        loan.SectionOfActType.should == '203b'
      end

      it "should be 502 for USDARuralHousing loans" do
        loan.stub MortgageType1: 'USDARuralHousing'
        loan.SectionOfActType.should == '502'
      end

      it "should be blank for other mortgage types" do
        loan.stub MortgageType1: 'slfjdslkj'
        loan.SectionOfActType.should == ''
      end
    end

    describe "#LoanManualUnderwritingIndicator" do
      it "should be false when AUSType is DU" do
        loan.stub AUSType: 'DU'
        loan.LoanManualUnderwritingIndicator.should == false
      end

      it "should be false when AUSType is LP" do
        loan.stub AUSType: 'LP'
        loan.LoanManualUnderwritingIndicator.should == false
      end

      it "should be true otherwise" do
        ['lsdfjf', 'NA', nil].each do |value|
          loan.stub AUSType: value
          loan.LoanManualUnderwritingIndicator.should == true
        end
      end
    end

    describe "#AutomatedUnderwritingSystemType" do
      it "should be 'DesktopUnderwriter' when AUSType is 'DU'" do
        loan.stub AUSType: 'DU'
        loan.AutomatedUnderwritingSystemType.should == 'DesktopUnderwriter'
      end

      it "should be 'LoanProspector' when AUSType is 'LP'" do
        loan.stub AUSType: 'LP'
        loan.AutomatedUnderwritingSystemType.should == 'LoanProspector'
      end

      it "should be blank otherwise" do
        ['lsdfjf', 'NA', nil].each do |value|
          loan.stub AUSType: value
          loan.AutomatedUnderwritingSystemType.should == ''
        end
      end
    end

    describe "#AutomatedUnderwritingCaseIdentifier" do
      it "should be blank if there is no automated underwriting system" do
        loan.stub AutomatedUnderwritingSystemType: ''
        loan.stub AUSKey: 'sldfkjdf'
        loan.AutomatedUnderwritingCaseIdentifier.should == ''
      end

      it "should be blank if the AUS is not LP" do
        loan.stub AutomatedUnderwritingSystemType: 'DesktopUnderwriter'
        loan.stub AUSKey: 'sldfkjdf'
        loan.AutomatedUnderwritingCaseIdentifier.should == ''
      end

      before { loan.stub AutomatedUnderwritingSystemType: 'LoanProspector' }
      it_behaves_like "a string with max length", :AutomatedUnderwritingCaseIdentifier,
        :AUSKey, 20
    end

    describe "#AutomatedUnderwritingRecommendationDescription" do
      describe 'LP' do
        before do
          loan.stub AUSType: 'LP'
        end
        it "Caution is default." do
          loan.stub AUSRecommendation: 'Blah'
          loan.AutomatedUnderwritingRecommendationDescription.should == 'Caution'
        end
        it 'Accept if exists' do
          loan.stub AUSRecommendation: 'Exempt/Accept/Accept'
          loan.AutomatedUnderwritingRecommendationDescription.should == 'Accept'
        end
        it 'is empty if N/A' do
          loan.stub AUSRecommendation: 'N/A'
          loan.AutomatedUnderwritingRecommendationDescription.should == ''
        end
      end

      describe 'DU' do
        before do
          loan.stub AUSType: 'DU'
        end
        it 'returns ApprovedEligible' do
          loan.stub AUSRecommendation: 'Blah'
          loan.AutomatedUnderwritingRecommendationDescription.should == 'ApproveEligible'
        end
        it 'blank values' do
          [nil, 'Out of Scope', 'Submit/Error'].each do |v|
            loan.stub AUSRecommendation: v
            loan.AutomatedUnderwritingRecommendationDescription.should == ''
          end
        end
      end
    end

    describe "#InvestorFeatureIdentifiers" do
      before { loan.valuation.stub additional_investor_features: [] }
      it "should be empty if StringSFC is empty" do
        [nil, 'NA', ''].each do |value|
          loan.stub StringSFC: value
          loan.InvestorFeatureIdentifiers.should == []
        end
      end

      it "should split the string in groups of three characters" do
        loan.stub StringSFC: '904H08903'
        loan.InvestorFeatureIdentifiers.should == ['904', '903']
      end

      ['904', 'H10', 'H03', '903'].each do |code|
        it "should include the #{code} code" do
          loan.stub StringSFC: code
          loan.InvestorFeatureIdentifiers.should include(code)
        end
      end

      ['003', '007', '221', 'abc', 'H08'].each do |code|
        it "should not include other codes" do
          loan.stub StringSFC: code
          loan.InvestorFeatureIdentifiers.should_not include(code)
        end
      end

      it "should add extra codes from the valuation object, discarding duplicates" do
        loan.stub StringSFC: 'H03'
        loan.valuation.stub additional_investor_features: [ 'H03', '904' ]
        loan.InvestorFeatureIdentifiers.should == [ 'H03', '904' ]
      end
    end

    describe "#ProjectClassificationIdentifier" do
      before do
        loan.stub ProductCode: 'Something FR'
        loan.stub ProjectType: 'RCondominium'
      end

      it "should be blank when the project is not a condo" do
          loan.stub AUSType: 'slkjfsd'
          loan.ProjectClassificationIdentifier.should == ''
        end
      context 'when AUSType is DU' do
        
        before {loan.stub AUSType: 'DU'}

        it 'Should return Project Eligibility Review services when it has pers ID and it is in Pers list' do
          loan.stub(:has_pers_id?).and_return(true)
          loan.stub(:in_pers_list?).and_return('Yes')
          expect(loan.ProjectClassificationIdentifier).to eq('Project Eligibility Review services')
        end

        it 'Should return CondominiumProjectManagerReview when it has pers ID and it is not in Pers list' do
          loan.stub(:has_pers_id?).and_return(true)
          loan.stub(:in_pers_list?).and_return('No')
          expect(loan.ProjectClassificationIdentifier).to eq('CondominiumProjectManagerReview')
        end

        [ ['PCondominium', 'StreamlinedReview'],
          ['QCondominium', 'StreamlinedReview'],
          ['RCondominium', 'FullReview'],
          ['SCondominium', 'FullReview'],
          ['VCondominium', 'V Refi Plus'],
          ['UCondominium', 'FHA_Approved'],
          ['Reciprocal Review', 'CondominiumProjectManagerReview'],
          ['TCondominium', 'CondominiumProjectManagerReview']
        ].each do |project_type, expected|
          it "should be #{expected} when FNMProjectType is #{project_type}" do
            loan.stub ProjectType: project_type
            loan.ProjectClassificationIdentifier.should == expected
          end
        end
      end

      context 'when AUSType is LP' do
        before {loan.stub AUSType: 'LP'}
        before { loan.stub FNMProjectType: 'Reciprocal Review' }

        it 'Should return Project Eligibility Review services when it has pers ID and it is in Pers list' do
          loan.stub(:has_pers_id?).and_return(true)
          loan.stub(:in_pers_list?).and_return('Yes')
          expect(loan.ProjectClassificationIdentifier).to eq('ProjectEligibilityReviewService')
        end

        it 'Should return CondominiumProjectManagerReview when it has pers ID and it is not in Pers list' do
          loan.stub(:has_pers_id?).and_return(true)
          loan.stub(:in_pers_list?).and_return('No')
          expect(loan.ProjectClassificationIdentifier).to eq('CondominiumProjectManagerReview')
        end

        [ ['PCondominium', 'StreamlinedReview'],
          ['QCondominium', 'StreamlinedReview'],
          ['RCondominium', 'FullReview'],
          ['SCondominium', 'FullReview'],
          ['2- to 4-unit Project', 'FullReview'],
          ['Detached Project', 'FullReview'],
          ['Established Project', 'FullReview'],
          ['New Project', 'FullReview']
        ].each do |project_type, expected|
          it "should be #{expected} when ProjectType is #{project_type}" do
            loan.stub FNMProjectType: project_type
            loan.ProjectClassificationIdentifier.should == expected
          end
        end


        context 'and ProjectType is something else' do
          before {loan.stub AUSType: 'LP'}
          before {loan.stub FNMProjectType: 'Streamlined Review' }

          it "should be Exempt when the product code ends in FR" do
            loan.stub ProductCode: 'C15FXD FR'
            loan.ProjectClassificationIdentifier.should == 'ExemptFromReview'
          end

          it "should be blank otherwise" do
            loan.stub ProductCode: 'foo'
            loan.ProjectClassificationIdentifier.should == 'StreamlinedReview'
          end
        end
      end
    end

    describe "#RefinanceCashOutAmount" do
      it "should be blank when LnPurpose is not refi" do
        loan.stub LnPurpose: 'Purchase'
        loan.stub CashOutAmt: 123.4567
        loan.RefinanceCashOutAmount.should == ''
      end

      context "when the loan is refinanced" do
        before { loan.stub LnPurpose: 'Refinance'}
        it_behaves_like "an amount with 2 decimal places", :RefinanceCashOutAmount, :CashOutAmt
      end
    end

    describe "#RefinanceCashOutDeterminationType" do
      ['CashOutOther', 'CashOutDebtConsolidation', 'CashOutHomeImprovement'].each do |value|
        it "should be CashOut when RefPurposeType is #{value}" do
          loan.stub RefPurposeType: value
          loan.RefinanceCashOutDeterminationType.should == 'CashOut'
        end
      end

      ['CashOutLimited', 'ChangeInRateTerm', 'NoCashOutFHAStreamlinedRefinance', 'VAStreamlinedRefinance'].each do |value|
        it "should be NoCashOut when RefPurposeType is #{value}" do
          loan.stub RefPurposeType: value
          loan.RefinanceCashOutDeterminationType.should == 'NoCashOut'
        end
      end

      it "should be blank otherwise" do
        ['NA', nil, '', 'sdlfkjds'].each do |value|
          loan.stub RefPurposeType: value
          loan.RefinanceCashOutDeterminationType.should == ''
        end
      end
    end

    describe "#RefinanceProgramIdentifier" do
      it "should be ReliefRefinanceOpenAccess if the product code ends in FR" do
        loan.stub ProductCode: "lasdfjdskljFR"
        loan.RefinanceProgramIdentifier.should == 'ReliefRefinanceOpenAccess'
      end

      it "should be blank for any other value" do
        ['NA', '', nil, 'C30FXD' ].each do |value|
          loan.stub ProductCode: value
          loan.RefinanceProgramIdentifier.should == ''
        end
      end
    end

    describe "#AggregateLoanCurtailmentAmount" do
      it_behaves_like "a number with decimal places", :AggregateLoanCurtailmentAmount, :CalcAggregateLoanCurtailments, 2
    end

    describe "#EscrowIndicator" do

      it "should be false when escrow has been waived" do
        loan.stub trid_loan?: true
        loan.stub EscrowWaiverFlg: 'Y'
        loan.EscrowIndicator.should == 'false'
      end

      it "should be true otherwise" do
        ['N', '', 'NA'].each do |value|
          loan.stub trid_loan?: true
          loan.stub EscrowWaiverFlg: value
          loan.EscrowIndicator.should == 'true'
        end
      end

      it "should be true when loan is not trid and has escrow items" do
        loan.stub trid_loan?: false
        hud_lines << make_hud_line(line_num: 1004, monthly_amount: 123.456, num_months: 12)
        expect(loan.EscrowIndicator).to eq 'true'
      end
    end

    describe "#FullName" do
      it "should be the institution name when channel starts with R0" do
        loan.stub LendingChannel: 'R0 - slfjf'
        loan.stub InstitutionName: 'Burger King'
        loan.FullName.should == 'Burger King'
      end

      it "should be Cole Taylor Bank for other channels" do
        loan.stub LendingChannel: 'W0 - slfjf'
        loan.stub InstitutionName: 'Burger King'
        loan.FullName.should == 'Cole Taylor Bank'
      end
    end


    describe "escrow items" do

      it "should have no escrow items when there are no hud lines" do
        hud_lines.should be_empty
        loan.escrow_items.should be_empty
      end

      it "should ignore hud lines that are not hudType HUD" do
        hud_lines << make_hud_line(line_num: 1005, monthly_amount: 123, hud_type: 'GFE', system_fee_name: "City Taxes")
        loan.escrow_items.should == []
      end

      it "should ignore the hud lines if fee_category is not equal to InitialEscrowPaymentAtClosing" do
        hud_lines << make_hud_line(line_num: 1003, monthly_amount: 12.456, num_months: 12, fee_category: "EscrowPayment", system_fee_name: "City Taxes")
        loan.escrow_items.should == []
      end

      it "should ignore the hud lines when NetFeeIndicator is false or nil" do
        hud_lines << make_hud_line(line_num: 1003, monthly_amount: 12.456, num_months: 12, fee_category: "InitialEscrowPaymentAtClosing", system_fee_name: "City Taxes", net_fee_indicator: false)
        hud_lines << make_hud_line(line_num: 1003, monthly_amount: 12.456, num_months: 12, fee_category: "InitialEscrowPaymentAtClosing", system_fee_name: "City Taxes", net_fee_indicator: nil)
        loan.escrow_items.should == []         
      end

      it "should include the hud lines when system fee name is Mortgage Insurance without checking fee category and net fee indicator" do
        hud_lines << make_hud_line(monthly_amount: 12.456, num_months: 12, fee_category: "InitialEscrowPaymentAtClosing", system_fee_name: "Mortgage Insurance", net_fee_indicator: false)
        expect(loan.escrow_items).to include(type: 'MortgageInsurance', amount: "12.46", months: 12)
      end

      [[ "Annual Assessments", "OtherTax"],
      [ "City Taxes", "CityPropertyTax"],
      ["County Taxes", "CountyPropertyTax"],
      ["Earthquake Insurance", "EarthquakeInsurance"],
      ["Flood Insurance", "FloodInsurance"],
      ["Homeowners Insurance", "HazardInsurance"],
      ["Hurricane Insurance", "StormInsurance"],
      ["Mortgage Insurance", "MortgageInsurance"],
      ["Other Insurance", "Other"],
      ["Property Taxes", "StatePropertyTax"],
      ["School Taxes", "SchoolPropertyTax"],
      ["Village Taxes", "TownshipPropertyTax"],
      ["Wind Insurance", "StormInsurance"]
      ].each do |value, expected|
        it "should return escrow agent type as #{expected} when system_fee_name is #{value}" do
          hud_lines << make_hud_line(system_fee_name: value, fee_category: "InitialEscrowPaymentAtClosing", monthly_amount: 12.34, num_months: 12, net_fee_indicator: true)
          expect(loan.escrow_items).to include(type: expected, amount: "12.34", months: 12)
        end
      end
    end


    describe "#LoanAcquisitionScheduledUPBAmount" do
      it "should be zero if the value is missing" do
        [0, nil].each do |value|
          loan.stub CalcSoldScheduledBal: value
          loan.LoanAcquisitionScheduledUPBAmount.should == '0.00'
        end
      end

      it "should round to 2 decimals" do
        loan.stub CalcSoldScheduledBal: 123.456
        loan.LoanAcquisitionScheduledUPBAmount.should == '123.46'
      end
    end

    describe "#BuydownInitialDiscountPercent" do
      it_behaves_like "a number with decimal places", :BuydownInitialDiscountPercent, :BuydownRatePercent, 4
    end

    describe "#BuydownChangeFrequencyMonthsCount" do
      it_behaves_like "an integer", :BuydownChangeFrequencyMonthsCount, :BuydownChangeFrequencyMonths
    end

    describe "#BuydownIncreaseRatePercent" do
      it_behaves_like "a number with decimal places", :BuydownIncreaseRatePercent, :BuydownIncreaseRatePct, 4
    end

    describe "#BuydownDurationMonthsCount" do
      it_behaves_like "an integer", :BuydownDurationMonthsCount, :BuydownDurationMonths
    end

    describe "#BuydownContributorType" do
      it_behaves_like "an enumeration", :BuydownContributorType, :BuydownContributorTypeOrig, ["Borrower", "Lender", "Other"]
    end

    describe "#PropertyStructureBuiltYear" do
      before { loan.stub YearBuilt: '1234' }

      it "should be 9999 when YearBuilt is nil" do
        loan.stub YearBuilt: nil
        loan.PropertyStructureBuiltYear.should == '9999'
      end

      it "should be 9999 when Product code matches the following ones" do
        ['C15FXD FR', 'C20FXD FR', 'C30FXD FR'].each do |pr_code|
          loan.stub ProductCode: pr_code
          loan.PropertyStructureBuiltYear.should == '9999'
        end
      end

      it "should be product code otherwise" do
        loan.PropertyStructureBuiltYear.should == '1234'
      end
    end

    describe "#OtherFundsCollectedAtClosingAmount" do
      it 'should handle when both the values are nil' do
        loan.stub EscrowAcctBal: nil
        loan.stub HUD1010AggregateAdj: nil
        expect(loan.OtherFundsCollectedAtClosingAmount).to eq ""
      end

      it 'subtracts HUD1010AggregateAdj from EscrowAcctBal when loan is trid' do
        loan.stub EscrowAcctBal: BigDecimal.new(30)
        loan.stub HUD1010AggregateAdj: BigDecimal.new(10)
        expect(loan.OtherFundsCollectedAtClosingAmount).to eq "20.00"
      end

      it "should return '' when EscrowIndicator is false" do
        loan.stub EscrowIndicator: 'false'
        loan.stub EscrowAcctBal: BigDecimal.new(30)
        expect(loan.OtherFundsCollectedAtClosingAmount).to eq ""
      end
    end

    describe '#OtherFundsCollectedAtClosingType' do
      context "when there are nonzero other funds collected" do
        before { loan.stub OtherFundsCollectedAtClosingAmount: '123.45' }
        it { loan.OtherFundsCollectedAtClosingType.should == 'EscrowFunds' }
      end
      context "when no funds are collected" do
        before { loan.stub OtherFundsCollectedAtClosingAmount: '' }
        it { loan.OtherFundsCollectedAtClosingType.should == '' }
      end
    end

    describe "#RelatedInvestorLoanIdentifier" do

    end

    describe "#RelatedLoanInvestorType" do
      before { loan.stub ProductCode: nil }

      it "should be FRE when the product code contains FR" do
        loan.stub ProductCode: 'slfj' + 'FR' + 'slkfjsdf'
        loan.RelatedLoanInvestorType.should == 'FRE'
      end

      it "should be blank otherwise" do
        loan.RelatedLoanInvestorType.should == ''
      end
    end

    describe 'LoanPurposeType' do
      [['Purchase', 'Purchase'],
       ['Refinance', 'Refinance'],
       ['anything_else', '']].each do |loan_purpose, purpose_type|
        it "should return #{purpose_type} when LnPurpose is #{loan_purpose}" do
          loan.stub LnPurpose: loan_purpose
          expect(loan.LoanPurposeType).to eq purpose_type
        end
      end
    end

    describe "borrowers" do
      before do
        loan.stub(:master_borrower).with(1) { Master::Person::Borrower.new(borrower_id: 'BRW1') }
        loan.stub(:master_borrower).with(2) { Master::Person::Borrower.new(borrower_id: 'BRW2') }
        loan.stub(:master_borrower).with(3) { Master::Person::Borrower.new(borrower_id: 'BRW3') }
        loan.stub(:master_borrower).with(4) { nil }
      end

      it "should include all of the borrowers that exist" do
        loan.borrowers.size.should == 3
      end
    end

    describe 'loan details fields' do
      it '#issue_date_lpb' do
        loan.stub('CalcSoldScheduledBal').and_return('1')
        loan.issue_date_upb.should == '1'
      end

      it '#curtailment' do
        loan.stub('AggregateLoanCurtailmentAmount').and_return('1')
        loan.curtailment.should == '1'
      end

      it '#first_payment_date' do
        loan.stub('ScheduledFirstPaymentDate').and_return('1')
        loan.first_payment_date.should == '1'
      end

      it '#last_paid_installment_date' do
        loan.stub('LastPaidInstallmentDueDate').and_return('1')
        loan.last_paid_installment_date.should == '1'
      end
    end

    context 'InvestorCollateralProgramIdentifier' do
      before do
        loan.stub AUSType: 'DU'
        loan.stub PropertyValuationMethodType: 'None'
      end

      ['LP', 'DU'].each do |aus|
        it 'should be PropertyInspectionWaver when valuation type is none and AUSType is #{aus}' do
          loan.stub('AUSType').and_return(aus)
          loan.stub('PropertyValuationMethodType').and_return('None')
          loan.InvestorCollateralProgramIdentifier.should == 'PropertyInspectionWaiver'
        end
      end

      it "should be blank if austype is something else" do
        loan.stub AUSType: 'NA'
        loan.InvestorCollateralProgramIdentifier.should == ''
      end

      it "should be blank if property val type is something else" do
        loan.stub PropertyValuationMethodType: 'aslfdjk'
        loan.InvestorCollateralProgramIdentifier.should == ''
      end
    end

    describe '#BorrowerCount' do
      before { subject.stub(:borrowers) { ['borrower1', 'borrower2']} }
      its(:BorrowerCount) { should == 2 }
    end
  end

  # reusable methods
  def make_hud_line(opts={})
    values = {
      line_num: 999,
      monthly_amount: 0,
      hud_type: 'HUD',
      num_months: 1
    }.merge(opts)
    Master::HudLine.new values, without_protection: true
  end
end
