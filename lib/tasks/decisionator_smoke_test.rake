namespace :ctm do

  desc "Decisionator smoke test"
  task :decisionator_smoke do
    require 'decisions/flow'

    failures = []

    flows = Decisions::Flow::FLOWS
    flows.each do |f, flow|
      begin
        required_fact_types = Ctmdecisionator::Flow.explain(flow[:name]).fact_types.map(&:model_mapping).uniq
        fact_types = FACT_TYPE_SMOKE_TEST_DATA.slice(*required_fact_types)
        response = Decisions::Flow.new(f, fact_types).execute
      rescue => e
        puts "#{f} failed:  exception was #{e.message}"
      end

      actual = response.slice(:errors, :warnings, :conclusion)
      # puts "#{f} => #{response.slice(:errors, :warnings, :conclusion)}"
      expected = DCSN_SMOKE_EXPECTED_RESPONSES[f]
      if expected == actual
        puts "#{f} is ok"
      else
        puts 
        puts "#{f} is not the expected response."
        puts "expected:"
        p expected
        puts "actual:"
        p actual
        failures << f
      end
    end

    puts
    if failures.any?
      puts "OVERALL: FAIL (#{failures.size} failures)"
    else
      puts "OVERALL: PASS"
    end
  end

  task :find_all_fact_types do
    loan = Loan.find(1000757)
    flows = Decisions::Flow::FLOWS
    fts = flows.map do |name, stuff|
      Decisions::Facttype.new(name, loan: loan, debug: true).execute
    end.inject &:merge
    fts.each do |k,v|
      fts[k] = v.to_s if v
    end
    p fts
  end

  FACT_TYPE_SMOKE_TEST_DATA = {
    "NumberOfUnits"=>"1",
    "LTV"=>"96.5",
    "TotalVerifiedBorrowerFunds"=>"9420.27",
    "TotalVerifiedAssets"=>"15920.27",
    "LoanProductName"=>"FHA30FXD",
    "PurposeOfLoan"=>"Purchase",
    "OccupancyType"=>"Primary",
    "TotalGiftAmount"=>"6500.0",
    "AUSRiskAssessment"=>"DU",
    "PropertyPurchasePrice"=>"256000.0",
    "LPOverrideReservesAmount"=>"7659.83",
    "UnderwritingStatus"=>"Final Approval/Ready For Docs",
    "AUSRecommendation"=>"Approve Eligible",
    "RiskAssessment"=>"AUS",
    "ChannelName"=>"Retail",
    "DTI"=>"49.089",
    "LowestFICOScore"=>"661",
    "HPMLStatus"=>"Not HPML",
    "FieldworkObtained"=>"Form 1004 appraisal with interior/exterior inspect",
    "EscrowWaiverIndicator1003"=>"No",
    "RateLockRequestEscrowWaiver"=>"No",
    "InitialRateLockDate"=>"08/03/2011",
    "InitialRateSheetDate"=>"09/06/2011",
    "SubmitToUnderwritingDate"=>"08/08/2011",
    "PurposeOfRefinance"=>nil,
    "TotalLoanAmountFirstMortgage"=>"247040.00",
    "CLTV"=>"96.5",
    "BaseLoanAmount1003"=>"247040.0",
    "FirstTimeHomebuyer"=>"Yes",
    "PropertyState"=>"PA",
    "SubordinateFinancing"=>"No",
    "CountyLoanLimit"=>"Failed to calculate CountyLoanLimit:  Unexpected response from County Loan Limit service (length)",
    "PropertyCountyName"=>"MONTGOMERY",
    "PropertyType"=>"Single Family Detached",
    "NumberOfFinancedProperties"=>"1",
    "HCLTV"=>"96.5",
    "IncomeDocExpirationDate"=>"09/07/2015",
    "FloodInsuranceIndicator"=>"No",
    "HomeownersInsuranceCondoMasterPolicyExpirationDate"=>nil,
    "FiveBusinessDaysFromToday"=>"11/27/2015",
    "CreditReportExpirationDate"=>"09/07/2015",
    "FloodInsuranceExpirationDate"=>nil,
    "HomeownersInsuranceExpirationDate"=>"09/07/2015",
    "AssetsDocExpirationDate"=>"09/07/2015",
    "AppraisalDocExpirationDate"=>"12/16/2011",
    "TitleDocExpirationDate"=>"09/07/2015",
    "CreditDocExpirationDate"=>"11/08/2011",
    "FloodInsuranceEffectiveDate"=>nil,
    "HomeownersInsuranceEffectiveDate"=>"09/07/2015",
    "TwoBusinessDaysFromToday"=> 2.business_days.from_now.strftime("%m/%d/%Y"),
    "ClosingDate"=>"09/16/2011",
    "ClosingPlusRescissionDate"=>"09/07/2015",
    "RateLockExpirationDate"=>"09/21/2011",
    "FundingDateCalendarCode"=>nil,
    "ClosingDateCalendarCode"=>nil,
    "FundingDate"=>"09/07/2015",
    "LoanStatus"=>"Purchased",
    "ProjectClassification"=>nil,
    "PERSListIndicator"=>nil,
    "PERSListExpirationDate"=>nil,
    "CPMProjectIDNumber"=>nil,
    "RateLockStatus"=>"Expired",
    "ProjectClassificationField1003"=>nil,
    "ProjectClassificationField1008"=>nil,
    "TRIDApplicationReceivedDate"=>nil,
    "TandIUnderwriting"=>"492.65",
    "TandIClosing"=>"339.18",
    "BorrowerTotalIncome"=>"5952.66",
    "FHATotalGiftAmount"=>"0",
    "ARMInitialAdjustmentPeriodGFE"=>nil,
    "InterestRate1003"=>"4.25",
    "AmortizationTypeGFE"=>"Fixed",
    "GFEMaximumInterestRate"=>nil,
    "CanMonthlyAmountRiseIndicator"=>"No",
    "PeriodicCAPLock"=>"0.0",
    "FirstRateAdjustmentCAPLock"=>"0.0",
    "LifetimeCAPLock"=>"0.0",
    "ARMIndexMargin1003"=>nil,
    "ARMIndexCode"=>nil,
    "ARMQualifyingRate"=>nil,
    "ARMInitialAdjustmentPeriod1003"=>nil,
    "FirstRateAdjustmentCAP1003"=>nil,
    "ARMSubsequentAdjustmentPeriod1003"=>nil,
    "PeriodicCAP1003"=>nil,
    "LifetimeCAP1003"=>nil,
    "UWConditionsBorrowerCreditScore"=>"767",
    "LockBorrowerCreditScore"=>"767",
    "DownloadedBorrowerCreditScore"=>nil,
    "DownloadedCoBorrowerCreditScore"=>nil,
    "UWConditionsCoBorrowerCreditScore"=>"661",
    "LockCoBorrowerCreditScore"=>"661",
    "OriginatorCompensationType"=>"Lender Paid",
    "RateLockRequestOriginatorCompensation"=>"Lender Paid",
    "TotalOriginatorCompensationAmount"=>nil,
    "TotalDiscountFeeAmount"=>nil,
    "TotalOriginationFeeAmount"=>nil,
    "TotalLenderCreditAmount"=>"4927.82",
    "TotalPremiumPricingAmount"=>"4927.82",
    "AppraisalType"=>"Actual",
    "PropertyAppraisedValue"=>"256000.0",
    "AppraiserLicenseState"=>"PA",
    "AppraisalCompanyName"=>"Property Services & Evaluations",
    "AppraisalYearBuilt"=>"1910",
    "AppraiserName"=>"John Durmala",
    "AppraiserLicenseNumber"=>"RL000022L",
    "LECreditReportFeeAmount"=>"14.75",
    "AttorneyDocPrepFee"=>nil,
    "LEFloodCertFeeAmount"=>nil,
    "Texas50A6Indicator"=>"Not 50A6",
    "LEAppraisalFeeAmount"=>"400.0",
    "LECondoQuestionnaireFeeAmount"=>nil,
    "ExistingSurveyIndicator"=>"No",
    "TitleVendorFeeAmount"=>nil,
    "SurveyFeeAmount"=>nil,
    "PestInspectionFeeAmount"=>nil,
    "IsThisACEMA"=>nil,
    "RecordingFeeAmount"=>nil,
    "TransferTaxAmount"=>nil,
    "MansionTaxAmount"=>nil,
    "TotalBoxGAmount"=>nil,
    "PUDIndicator"=>"No",
    "OfferingIdentifier"=>nil,
    "VAHomebuyerUsageIndicator"=>nil,
    "TypeOfVeteran"=>nil,
    "IsVeteranExempt"=>nil,
    "DownpaymentPercentage"=>"-3.5",
    "ClosingCannotOccurUntilDate"=>"09/12/2011",
    "NoticeOfSpecialFloodHazardsDeliveryDate"=>nil,
    "CDProofOfReceiptDate"=>nil,
    "ClosingVerificationsExpirationDate"=>nil,
    "ClosingRequestSubmittedPlus10BusinessDate"=>"09/23/2011",
    "CloserCDFlag"=>"Yes",
    "InitialLESentDate"=>"08/04/2011",
    "IntentToProceedDate"=>nil,
    "BrokerNMLSNumber"=>"",
    "LoanOfficerName"=>"Lori Radcliff",
    "LoanOfficerNMLSNumber"=>"518349",
    "DaysSinceApplicationReceived"=>nil,
    "MaximumClosingDate"=>"Acceptable",
    "MinimumClosingDate"=>"Acceptable",
    "ClosingFeeToleranceDate"=>nil,
    "StateHousingDocumentPrepFee"=>nil,
    "StateHousingOriginationFee"=>nil,
    "StateHousingUnderwritingFee"=>nil,
    "LockNetPrice"=>"101.975",
    "EmployeeLoanIndicator"=>"Not Employee",
    "NoLenderAdminFeeLLPAIndicator"=>"No",
    "BoxADiscountPercentage"=>nil,
    "LockDiscountPercentage"=>nil,
    "AdministrationFee"=>nil,
    "UpfrontMIPPercentage"=>"1.0",
    "USDAConditionalCommitmentDate"=>nil,
    "RequestedMortgageInsuranceType"=>nil,
    "MortgageInsuranceLTV"=>"96.5",
    "LineNAmount"=>"2470.0",
    "UpfrontGuaranteeFeePercentage"=>"0.99",
    "MonthlyGuaranteeFeePercentage"=>"1.14",
    "LineGAmount"=>"2470.4",
    "LoanTermMonths"=>"360",
    "RateLockRequestLenderPaidMI"=>"No",
    "HARPTypeOfMI"=>nil,
    "MIProgram"=>nil,
    "VAFundingFeeAmount"=>nil,
    "VAFundingFeePercentage"=>nil,
    "RateLockRequestMIRequired"=>"No",
    "WEBVAFundingFeePercentage"=>"Acceptable",
    "MICoveragePercentage"=>nil,
    "FHAEndorsementDate"=>nil,
    "MonthlyMIPPercentage"=>"1.15",
    "ProposedMonthlyMortgageInsurancePayment"=>"234.93",
    "MICertificationNumber"=>nil,
    "FloodEscrowAmount" => "123.45",
    "FloodEscrowMonths" => 5,
    "TotalEscrowAmount" => "123.45",
    "TotalEscrowMonths" => 5,
  }

  DCSN_SMOKE_EXPECTED_RESPONSES = {
    :asset_acceptance => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :aus => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :dti => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :hpml_compliance => {:errors=>[{:rule_id=>65, :text=>"Form 1004 appraisal with interior/exterior inspect is not a valid option for Fieldwork Obtained."}], :warnings=>[], :conclusion=>"Not Valid"},
    :product_eligibility => {:errors=>[{:rule_id=>1025, :text=>"Loans with qualification dates prior to 6/1/2013 must be manually qualified 1312387200000 ."}], :warnings=>[], :conclusion=>"Manual"},
    :ausreg => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :documents_expiration_dates_acceptance => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :preclosing => {:errors=>[{:rule_id=>68, :text=>"Closing Date Calendar code must have a value. This data is external to the system."}, {:rule_id=>68, :text=>"Funding Date Calendar code must have a value. This data is external to the system."}], :warnings=>[], :conclusion=>"Not Complete"},
    :florida_condo_acceptance => {:errors=>[{:rule_id=>70, :text=>"County Loan Limit must have a value for FHA30FXD .  Please verify the spelling of the subject property's address and county."}], :warnings=>[], :conclusion=>"Not Complete"},
    :project_classification_1008_acceptance => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :ratio_change_acceptance => {:errors=>[{:rule_id=>72, :text=>"For FHA loans, the FHA Total Gift Amount must be greater than or equal to the sum of the gifts listed as assets."}], :warnings=>[], :conclusion=>"Not Valid"},
    :escrow_waiver_acceptance => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :arm_gfe_acceptance => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :arm_rate_lock_acceptance => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :arm_1003_acceptance => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :rate_lock_expiration_dates => {:errors=>[{:rule_id=>79, :text=>"The Rate Lock expires before the Funding date."}], :warnings=>[], :conclusion=>"Not Acceptable"},
    :credit_score_comparison_acceptance => {:errors=>[], :warnings=>[{:rule_id=>81, :text=>"Please ensure the credit scores on the credit report match the credit scores on the underwriter conditions screen and the lock screen."}], :conclusion=>"Acceptable"},
    :compensation_acceptance => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :appraisal_acceptance => {:errors=>[{:rule_id=>83, :text=>"Form 1004 appraisal with interior/exterior inspect is not a valid option for Fieldwork Obtained."}], :warnings=>[], :conclusion=>"Not Valid"},
    :le_box_b => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :le_box_c => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :le_box_e_acceptance => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :le_box_g => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :determine_cd_recipients => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :other_data_1003 => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :va_funding_fee_amt => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :minimum_closing_date => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :maximum_closing_date => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :insurance_documents_acceptance => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :disclosure_method => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :intent_to_proceed => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :le_page_three => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :application_date_compliance => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :closing_verification_date_acceptance => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :closing_date => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :le_box_a => {:errors=>[], :warnings=>[], :conclusion=>"Acceptable"},
    :mortgage_insurance => {:errors=>[], :warnings=>[{:rule_id=>108, :text=>"Please manually determine if MI is required and entered correctly."}], :conclusion=>"Manual"},
  }

end

