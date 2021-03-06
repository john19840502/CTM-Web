require 'spec_helper'

describe Delivery::FnmaCashController do
  render_views

  before do
    u = fake_rubycas_login
  end

  describe "GET 'index'" do
    before do
      Smds::CashCommitment.should_receive(:create_all).and_return(true)
      get :index
    end

    it { should render_template 'index' }
  end

  describe 'get :filter_by_date' do
    before do
      get :filter_by_date, start_date: '01-01-2012', end_date: '01-02-2012'
    end

    it { should render_template 'filter_by_date' }
  end

  describe 'get :export with an arm loan' do
    let(:commitment) { Smds::CashCommitment.new }
    let(:loan) { FnmaLoan.find(8000731) }
    let(:loans) { [loan] }

    before do
      loan.stub(:arm?) { true }
      loan.stub(:CurrLTV) {70}
      time = Time.new(2014,6,17)
      Time.stub(:now) { time }
      Date.stub(:today) { Date.new(2014,6,17) }
      commitment.stub(:loans) { loans }
      subject.stub_chain(:delivery_model, :find) { commitment }
      get :export, record_id: '12345', format: :xml
    end

    it 'should be awesome' do
      response.should be_success
      response.body.should == <<eos
<?xml version="1.0" encoding="UTF-8"?>
<MESSAGE MISMOReferenceModelIdentifier="3.0.0.263.12" xmlns="http://www.mismo.org/residential/2009/schemas" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <ABOUT_VERSIONS>
    <ABOUT_VERSION>
      <AboutVersionIdentifier>FNM 1.0</AboutVersionIdentifier>
      <CreatedDatetime>2014-06-17T04:00:00</CreatedDatetime>
    </ABOUT_VERSION>
  </ABOUT_VERSIONS>
  <DEAL_SETS>
    <DEAL_SET>
      <DEALS>
        <DEAL>
          <COLLATERALS>
            <COLLATERAL>
              <PROPERTIES>
                <PROPERTY>
                  <ADDRESS>
                    <AddressLineText>1621 Lone Star Blvd</AddressLineText>
                    <CityName>Terrell</CityName>
                    <PostalCode>75160</PostalCode>
                    <StateCode>TX</StateCode>
                  </ADDRESS>
                  <FLOOD_DETERMINATION>
                    <FLOOD_DETERMINATION_DETAIL>
                      <SpecialFloodHazardAreaIndicator>false</SpecialFloodHazardAreaIndicator>
                    </FLOOD_DETERMINATION_DETAIL>
                  </FLOOD_DETERMINATION>
                  <PROJECT>
                    <PROJECT_DETAIL>
                      <ProjectClassificationIdentifier>E</ProjectClassificationIdentifier>
                      <PUDIndicator>true</PUDIndicator>
                    </PROJECT_DETAIL>
                  </PROJECT>
                  <PROPERTY_DETAIL>
                    <ConstructionMethodType>SiteBuilt</ConstructionMethodType>
                    <FinancedUnitCount>1</FinancedUnitCount>
                    <PropertyEstateType>FeeSimple</PropertyEstateType>
                    <PropertyFloodInsuranceIndicator>false</PropertyFloodInsuranceIndicator>
                    <PropertyStructureBuiltYear>2003</PropertyStructureBuiltYear>
                    <PropertyUsageType>PrimaryResidence</PropertyUsageType>
                  </PROPERTY_DETAIL>
                  <PROPERTY_UNITS>
                    <PROPERTY_UNIT>
                      <PROPERTY_UNIT_DETAIL>
                      </PROPERTY_UNIT_DETAIL>
                    </PROPERTY_UNIT>
                    <PROPERTY_UNIT>
                      <PROPERTY_UNIT_DETAIL>
                      </PROPERTY_UNIT_DETAIL>
                    </PROPERTY_UNIT>
                    <PROPERTY_UNIT>
                      <PROPERTY_UNIT_DETAIL>
                      </PROPERTY_UNIT_DETAIL>
                    </PROPERTY_UNIT>
                    <PROPERTY_UNIT>
                      <PROPERTY_UNIT_DETAIL>
                      </PROPERTY_UNIT_DETAIL>
                    </PROPERTY_UNIT>
                  </PROPERTY_UNITS>
                  <PROPERTY_VALUATIONS>
                    <PROPERTY_VALUATION>
                      <AVMS>
                        <AVM>
                        </AVM>
                      </AVMS>
                      <PROPERTY_VALUATION_DETAIL>
                        <PropertyValuationAmount>184000</PropertyValuationAmount>
                        <PropertyValuationEffectiveDate>2011-12-19</PropertyValuationEffectiveDate>
                      </PROPERTY_VALUATION_DETAIL>
                    </PROPERTY_VALUATION>
                  </PROPERTY_VALUATIONS>
                </PROPERTY>
              </PROPERTIES>
            </COLLATERAL>
          </COLLATERALS>
          <LOANS>
            <COMBINED_LTVS>
              <COMBINED_LTV>
                <CombinedLTVRatioPercent>95</CombinedLTVRatioPercent>
                <HomeEquityCombinedLTVRatioPercent>95</HomeEquityCombinedLTVRatioPercent>
              </COMBINED_LTV>
            </COMBINED_LTVS>
            <LOAN LoanRoleType="SubjectLoan">
              <ADJUSTMENT>
                <INTEREST_RATE_ADJUSTMENT>
                  <INDEX_RULES>
                    <INDEX_RULE>
                      <IndexSourceType>Other</IndexSourceType>
                      <IndexSourceTypeOtherDescription>1YearWallStreetJournalLIBORRateDaily</IndexSourceTypeOtherDescription>
                      <InterestAndPaymentAdjustmentIndexLeadDaysCount>45</InterestAndPaymentAdjustmentIndexLeadDaysCount>
                    </INDEX_RULE>
                  </INDEX_RULES>
                  <INTEREST_RATE_LIFETIME_ADJUSTMENT_RULE>
                    <CeilingRatePercent>0.0</CeilingRatePercent>
                    <InterestRateRoundingPercent>0.125</InterestRateRoundingPercent>
                    <InterestRateRoundingType>Nearest</InterestRateRoundingType>
                    <MarginRatePercent>0.0</MarginRatePercent>
                  </INTEREST_RATE_LIFETIME_ADJUSTMENT_RULE>
                  <INTEREST_RATE_PER_CHANGE_ADJUSTMENT_RULES>
                    <INTEREST_RATE_PER_CHANGE_ADJUSTMENT_RULE>
                      <AdjustmentRuleType>First</AdjustmentRuleType>
                      <PerChangeMaximumDecreaseRatePercent>0.0</PerChangeMaximumDecreaseRatePercent>
                      <PerChangeMaximumIncreaseRatePercent>0.0</PerChangeMaximumIncreaseRatePercent>
                    </INTEREST_RATE_PER_CHANGE_ADJUSTMENT_RULE>
                    <INTEREST_RATE_PER_CHANGE_ADJUSTMENT_RULE>
                      <AdjustmentRuleType>Subsequent</AdjustmentRuleType>
                      <PerChangeMaximumDecreaseRatePercent>0.0</PerChangeMaximumDecreaseRatePercent>
                      <PerChangeMaximumIncreaseRatePercent>0.0</PerChangeMaximumIncreaseRatePercent>
                    </INTEREST_RATE_PER_CHANGE_ADJUSTMENT_RULE>
                  </INTEREST_RATE_PER_CHANGE_ADJUSTMENT_RULES>
                </INTEREST_RATE_ADJUSTMENT>
              </ADJUSTMENT>
              <AMORTIZATION>
                <AMORTIZATION_RULE>
                  <LoanAmortizationPeriodCount>180</LoanAmortizationPeriodCount>
                  <LoanAmortizationPeriodType>Month</LoanAmortizationPeriodType>
                  <LoanAmortizationType>Fixed</LoanAmortizationType>
                </AMORTIZATION_RULE>
              </AMORTIZATION>
              <FORM_SPECIFIC_CONTENTS>
                <FORM_SPECIFIC_CONTENT>
                  <URLA>
                    <URLA_DETAIL>
                      <PurchasePriceAmount>174750</PurchasePriceAmount>
                    </URLA_DETAIL>
                  </URLA>
                </FORM_SPECIFIC_CONTENT>
              </FORM_SPECIFIC_CONTENTS>
              <GOVERNMENT_LOAN>
              </GOVERNMENT_LOAN>
              <HMDA_LOAN>
                <HMDA_HOEPALoanStatusIndicator>false</HMDA_HOEPALoanStatusIndicator>
              </HMDA_LOAN>
              <INTEREST_CALCULATION>
                <INTEREST_CALCULATION_RULES>
                  <INTEREST_CALCULATION_RULE>
                    <InterestCalculationPeriodType>Month</InterestCalculationPeriodType>
                    <InterestCalculationType>Compound</InterestCalculationType>
                  </INTEREST_CALCULATION_RULE>
                </INTEREST_CALCULATION_RULES>
              </INTEREST_CALCULATION>
              <INVESTOR_LOAN_INFORMATION>
              </INVESTOR_LOAN_INFORMATION>
              <LOAN_DETAIL>
                <AssumabilityIndicator>false</AssumabilityIndicator>
                <BalloonIndicator>false</BalloonIndicator>
                <BorrowerCount>1</BorrowerCount>
                <BuydownTemporarySubsidyIndicator>false</BuydownTemporarySubsidyIndicator>
                <CapitalizedLoanIndicator>false</CapitalizedLoanIndicator>
                <ConstructionLoanIndicator>false</ConstructionLoanIndicator>
                <ConvertibleIndicator>false</ConvertibleIndicator>
                <EscrowIndicator>false</EscrowIndicator>
                <InterestOnlyIndicator>false</InterestOnlyIndicator>
                <LoanAffordableIndicator>false</LoanAffordableIndicator>
                <PrepaymentPenaltyIndicator>false</PrepaymentPenaltyIndicator>
                <RelocationLoanIndicator>false</RelocationLoanIndicator>
                <SharedEquityIndicator>false</SharedEquityIndicator>
              </LOAN_DETAIL>
              <LOAN_LEVEL_CREDIT>
                <LOAN_LEVEL_CREDIT_DETAIL>
                  <LoanLevelCreditScoreValue>781</LoanLevelCreditScoreValue>
                </LOAN_LEVEL_CREDIT_DETAIL>
              </LOAN_LEVEL_CREDIT>
              <LOAN_STATE>
                <LoanStateDate>2012-01-04</LoanStateDate>
                <LoanStateType>AtClosing</LoanStateType>
              </LOAN_STATE>
              <LTV>
                <LTVRatioPercent>80</LTVRatioPercent>
              </LTV>
              <MATURITY>
                <MATURITY_RULE>
                  <LoanMaturityDate>2027-01-01</LoanMaturityDate>
                  <LoanMaturityPeriodCount>180</LoanMaturityPeriodCount>
                  <LoanMaturityPeriodType>Month</LoanMaturityPeriodType>
                </MATURITY_RULE>
              </MATURITY>
              <PAYMENT>
                <PAYMENT_RULE>
                  <InitialPrincipalAndInterestPaymentAmount>999.41</InitialPrincipalAndInterestPaymentAmount>
                  <PaymentFrequencyType>Monthly</PaymentFrequencyType>
                  <ScheduledFirstPaymentDate>2012-02-01</ScheduledFirstPaymentDate>
                </PAYMENT_RULE>
              </PAYMENT>
              <QUALIFICATION>
                <BorrowerReservesMonthlyPaymentCount>0</BorrowerReservesMonthlyPaymentCount>
                <TotalLiabilitiesMonthlyPaymentAmount>2185</TotalLiabilitiesMonthlyPaymentAmount>
                <TotalMonthlyIncomeAmount>6788</TotalMonthlyIncomeAmount>
                <TotalMonthlyProposedHousingExpenseAmount>1745</TotalMonthlyProposedHousingExpenseAmount>
              </QUALIFICATION>
              <REFINANCE>
              </REFINANCE>
              <SELECTED_LOAN_PRODUCT>
                <PRICE_LOCKS>
                  <PRICE_LOCK>
                    <PriceLockDatetime>2011-12-21</PriceLockDatetime>
                  </PRICE_LOCK>
                </PRICE_LOCKS>
              </SELECTED_LOAN_PRODUCT>
              <TERMS_OF_MORTGAGE>
                <LienPriorityType>FirstLien</LienPriorityType>
                <LoanPurposeType>Purchase</LoanPurposeType>
                <MortgageType>Conventional</MortgageType>
                <NoteAmount>139800.00</NoteAmount>
                <NoteDate>2012-01-04</NoteDate>
                <NoteRatePercent>3.5000</NoteRatePercent>
              </TERMS_OF_MORTGAGE>
              <UNDERWRITING>
                <AUTOMATED_UNDERWRITINGS>
                  <AUTOMATED_UNDERWRITING>
                    <AutomatedUnderwritingCaseIdentifier>1058880853</AutomatedUnderwritingCaseIdentifier>
                    <AutomatedUnderwritingRecommendationDescription>ApproveEligible</AutomatedUnderwritingRecommendationDescription>
                    <AutomatedUnderwritingSystemType>DesktopUnderwriter</AutomatedUnderwritingSystemType>
                  </AUTOMATED_UNDERWRITING>
                </AUTOMATED_UNDERWRITINGS>
                <UNDERWRITING_DETAIL>
                  <LoanManualUnderwritingIndicator>false</LoanManualUnderwritingIndicator>
                </UNDERWRITING_DETAIL>
              </UNDERWRITING>
            </LOAN>
            <LOAN LoanRoleType="SubjectLoan">
              <ADJUSTMENT>
                <RATE_OR_PAYMENT_CHANGE_OCCURRENCES>
                  <RATE_OR_PAYMENT_CHANGE_OCCURRENCE>
                  </RATE_OR_PAYMENT_CHANGE_OCCURRENCE>
                </RATE_OR_PAYMENT_CHANGE_OCCURRENCES>
              </ADJUSTMENT>
              <INVESTOR_FEATURES>
                <INVESTOR_FEATURE>
                </INVESTOR_FEATURE>
                <INVESTOR_FEATURE>
                </INVESTOR_FEATURE>
                <INVESTOR_FEATURE>
                </INVESTOR_FEATURE>
                <INVESTOR_FEATURE>
                </INVESTOR_FEATURE>
                <INVESTOR_FEATURE>
                </INVESTOR_FEATURE>
                <INVESTOR_FEATURE>
                </INVESTOR_FEATURE>
              </INVESTOR_FEATURES>
              <INVESTOR_LOAN_INFORMATION>
                <InvestorOwnershipPercent>100</InvestorOwnershipPercent>
                <InvestorRemittanceType>ActualInterestActualPrincipal</InvestorRemittanceType>
              </INVESTOR_LOAN_INFORMATION>
              <LOAN_DETAIL>
                <MortgageModificationIndicator>false</MortgageModificationIndicator>
              </LOAN_DETAIL>
              <LOAN_IDENTIFIERS>
                <LOAN_IDENTIFIER>
                  <InvestorCommitmentIdentifier>574886</InvestorCommitmentIdentifier>
                </LOAN_IDENTIFIER>
                <LOAN_IDENTIFIER>
                  <MERS_MINIdentifier>100880800080007319</MERS_MINIdentifier>
                </LOAN_IDENTIFIER>
                <LOAN_IDENTIFIER>
                  <SellerLoanIdentifier>8000731</SellerLoanIdentifier>
                </LOAN_IDENTIFIER>
              </LOAN_IDENTIFIERS>
              <LOAN_PROGRAMS>
                <LOAN_PROGRAM>
                </LOAN_PROGRAM>
              </LOAN_PROGRAMS>
              <LOAN_STATE>
                <LoanStateDate>2014-06-17</LoanStateDate>
                <LoanStateType>Current</LoanStateType>
              </LOAN_STATE>
              <MI_DATA>
                <MI_DATA_DETAIL>
                  <PrimaryMIAbsenceReasonType>NoMIBasedOnOriginalLTV</PrimaryMIAbsenceReasonType>
                </MI_DATA_DETAIL>
              </MI_DATA>
              <PAYMENT>
                <PAYMENT_COMPONENT_BREAKOUTS>
                  <PAYMENT_COMPONENT_BREAKOUT>
                    <PrincipalAndInterestPaymentAmount>999.41</PrincipalAndInterestPaymentAmount>
                  </PAYMENT_COMPONENT_BREAKOUT>
                </PAYMENT_COMPONENT_BREAKOUTS>
                <PAYMENT_SUMMARY>
                  <LastPaidInstallmentDueDate>2012-01-01</LastPaidInstallmentDueDate>
                  <UPBAmount>139800.00</UPBAmount>
                </PAYMENT_SUMMARY>
              </PAYMENT>
              <SELECTED_LOAN_PRODUCT>
                <LOAN_PRODUCT_DETAIL>
                </LOAN_PRODUCT_DETAIL>
              </SELECTED_LOAN_PRODUCT>
              <SERVICING>
                <DELINQUENCY_SUMMARY>
                  <DelinquentPaymentsOverPastTwelveMonthsCount>0</DelinquentPaymentsOverPastTwelveMonthsCount>
                </DELINQUENCY_SUMMARY>
              </SERVICING>
            </LOAN>
          </LOANS>
          <PARTIES>
            <PARTY>
              <ROLES>
                <PARTY_ROLE_IDENTIFIERS>
                  <PARTY_ROLE_IDENTIFIER>
                    <PartyRoleIdentifier>99999398668</PartyRoleIdentifier>
                  </PARTY_ROLE_IDENTIFIER>
                </PARTY_ROLE_IDENTIFIERS>
                <ROLE>
                  <ROLE_DETAIL>
                    <PartyRoleType>DocumentCustodian</PartyRoleType>
                  </ROLE_DETAIL>
                </ROLE>
              </ROLES>
            </PARTY>
            <PARTY>
              <ROLES>
                <PARTY_ROLE_IDENTIFIERS>
                  <PARTY_ROLE_IDENTIFIER>
                    <PartyRoleIdentifier>370420</PartyRoleIdentifier>
                  </PARTY_ROLE_IDENTIFIER>
                </PARTY_ROLE_IDENTIFIERS>
                <ROLE>
                  <ROLE_DETAIL>
                    <PartyRoleType>LoanOriginationCompany</PartyRoleType>
                  </ROLE_DETAIL>
                </ROLE>
              </ROLES>
            </PARTY>
            <PARTY>
              <ROLES>
                <PARTY_ROLE_IDENTIFIERS>
                  <PARTY_ROLE_IDENTIFIER>
                    <PartyRoleIdentifier>266128</PartyRoleIdentifier>
                  </PARTY_ROLE_IDENTIFIER>
                </PARTY_ROLE_IDENTIFIERS>
                <ROLE>
                  <LOAN_ORIGINATOR>
                    <LoanOriginatorType>Correspondent</LoanOriginatorType>
                  </LOAN_ORIGINATOR>
                  <ROLE_DETAIL>
                    <PartyRoleType>LoanOriginator</PartyRoleType>
                  </ROLE_DETAIL>
                </ROLE>
              </ROLES>
            </PARTY>
            <PARTY>
              <ROLES>
                <PARTY_ROLE_IDENTIFIERS>
                  <PARTY_ROLE_IDENTIFIER>
                    <PartyRoleIdentifier>272190003</PartyRoleIdentifier>
                  </PARTY_ROLE_IDENTIFIER>
                </PARTY_ROLE_IDENTIFIERS>
                <ROLE>
                  <ROLE_DETAIL>
                    <PartyRoleType>LoanSeller</PartyRoleType>
                  </ROLE_DETAIL>
                </ROLE>
              </ROLES>
            </PARTY>
            <PARTY>
              <LEGAL_ENTITY>
                <LEGAL_ENTITY_DETAIL>
                  <FullName>Southern Star Capital, LLC dba Reliance Mortgage C</FullName>
                </LEGAL_ENTITY_DETAIL>
              </LEGAL_ENTITY>
              <ROLES>
                <ROLE>
                  <ROLE_DETAIL>
                    <PartyRoleType>NotePayTo</PartyRoleType>
                  </ROLE_DETAIL>
                </ROLE>
              </ROLES>
            </PARTY>
            <PARTY>
              <ROLES>
                <PARTY_ROLE_IDENTIFIERS>
                  <PARTY_ROLE_IDENTIFIER>
                    <PartyRoleIdentifier>002003402</PartyRoleIdentifier>
                  </PARTY_ROLE_IDENTIFIER>
                </PARTY_ROLE_IDENTIFIERS>
                <ROLE>
                  <ROLE_DETAIL>
                    <PartyRoleType>Payee</PartyRoleType>
                  </ROLE_DETAIL>
                </ROLE>
              </ROLES>
            </PARTY>
            <PARTY>
              <ROLES>
                <PARTY_ROLE_IDENTIFIERS>
                  <PARTY_ROLE_IDENTIFIER>
                    <PartyRoleIdentifier>272190003</PartyRoleIdentifier>
                  </PARTY_ROLE_IDENTIFIER>
                </PARTY_ROLE_IDENTIFIERS>
                <ROLE>
                  <ROLE_DETAIL>
                    <PartyRoleType>Servicer</PartyRoleType>
                  </ROLE_DETAIL>
                </ROLE>
              </ROLES>
            </PARTY>
          </PARTIES>
        </DEAL>
      </DEALS>
      <PARTIES>
        <PARTY>
          <ROLES>
            <PARTY_ROLE_IDENTIFIERS>
              <PARTY_ROLE_IDENTIFIER>
                <PartyRoleIdentifier>99999398668</PartyRoleIdentifier>
              </PARTY_ROLE_IDENTIFIER>
            </PARTY_ROLE_IDENTIFIERS>
            <ROLE>
              <ROLE_DETAIL>
                <PartyRoleType>DocumentCustodian</PartyRoleType>
              </ROLE_DETAIL>
            </ROLE>
          </ROLES>
        </PARTY>
        <PARTY>
          <ROLES>
            <PARTY_ROLE_IDENTIFIERS>
              <PARTY_ROLE_IDENTIFIER>
                <PartyRoleIdentifier>272190003</PartyRoleIdentifier>
              </PARTY_ROLE_IDENTIFIER>
            </PARTY_ROLE_IDENTIFIERS>
            <ROLE>
              <ROLE_DETAIL>
                <PartyRoleType>LoanSeller</PartyRoleType>
              </ROLE_DETAIL>
            </ROLE>
          </ROLES>
        </PARTY>
        <PARTY>
          <ROLES>
            <PARTY_ROLE_IDENTIFIERS>
              <PARTY_ROLE_IDENTIFIER>
                <PartyRoleIdentifier>272190003</PartyRoleIdentifier>
              </PARTY_ROLE_IDENTIFIER>
            </PARTY_ROLE_IDENTIFIERS>
            <ROLE>
              <ROLE_DETAIL>
                <PartyRoleType>Servicer</PartyRoleType>
              </ROLE_DETAIL>
            </ROLE>
          </ROLES>
        </PARTY>
      </PARTIES>
    </DEAL_SET>
    <PARTIES>
      <PARTY>
        <ROLES>
          <PARTY_ROLE_IDENTIFIERS>
            <PARTY_ROLE_IDENTIFIER>
              <PartyRoleIdentifier>VASIAA01D</PartyRoleIdentifier>
            </PARTY_ROLE_IDENTIFIER>
          </PARTY_ROLE_IDENTIFIERS>
          <ROLE>
            <ROLE_DETAIL>
              <PartyRoleType>LoanDeliveryFilePreparer</PartyRoleType>
            </ROLE_DETAIL>
          </ROLE>
        </ROLES>
      </PARTY>
    </PARTIES>
  </DEAL_SETS>
</MESSAGE>
eos
    end
  end

  describe 'get :export' do
    let(:commitment) { Smds::CashCommitment.new }
    let(:loan) { FnmaLoan.find(1004919) }
    let(:loans) { [loan] }

    before do
      time = Time.new(2014,6,17)
      Time.stub(:now) { time }
      loan.stub(:CurrLTV) {70}
      Date.stub(:today) { Date.new(2014,6,17) }
      commitment.stub(:loans) { loans }
      subject.stub_chain(:delivery_model, :find) { commitment }
      get :export, record_id: '12345', format: :xml
    end

    it 'should be awesome' do
      response.should be_success
      response.body.should == <<-eos
<?xml version="1.0" encoding="UTF-8"?>
<MESSAGE MISMOReferenceModelIdentifier="3.0.0.263.12" xmlns="http://www.mismo.org/residential/2009/schemas" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <ABOUT_VERSIONS>
    <ABOUT_VERSION>
      <AboutVersionIdentifier>FNM 1.0</AboutVersionIdentifier>
      <CreatedDatetime>2014-06-17T04:00:00</CreatedDatetime>
    </ABOUT_VERSION>
  </ABOUT_VERSIONS>
  <DEAL_SETS>
    <DEAL_SET>
      <DEALS>
        <DEAL>
          <COLLATERALS>
            <COLLATERAL>
              <PROPERTIES>
                <PROPERTY>
                  <ADDRESS>
                    <AddressLineText>6451 Garfield Ridge Court</AddressLineText>
                    <CityName>Willowbrook</CityName>
                    <PostalCode>60527</PostalCode>
                    <StateCode>IL</StateCode>
                  </ADDRESS>
                  <FLOOD_DETERMINATION>
                    <FLOOD_DETERMINATION_DETAIL>
                      <SpecialFloodHazardAreaIndicator>false</SpecialFloodHazardAreaIndicator>
                    </FLOOD_DETERMINATION_DETAIL>
                  </FLOOD_DETERMINATION>
                  <PROJECT>
                    <PROJECT_DETAIL>
                      <ProjectClassificationIdentifier>G</ProjectClassificationIdentifier>
                      <PUDIndicator>false</PUDIndicator>
                    </PROJECT_DETAIL>
                  </PROJECT>
                  <PROPERTY_DETAIL>
                    <ConstructionMethodType>SiteBuilt</ConstructionMethodType>
                    <FinancedUnitCount>1</FinancedUnitCount>
                    <PropertyEstateType>FeeSimple</PropertyEstateType>
                    <PropertyFloodInsuranceIndicator>false</PropertyFloodInsuranceIndicator>
                    <PropertyStructureBuiltYear>1987</PropertyStructureBuiltYear>
                    <PropertyUsageType>PrimaryResidence</PropertyUsageType>
                  </PROPERTY_DETAIL>
                  <PROPERTY_UNITS>
                    <PROPERTY_UNIT>
                      <PROPERTY_UNIT_DETAIL>
                      </PROPERTY_UNIT_DETAIL>
                    </PROPERTY_UNIT>
                    <PROPERTY_UNIT>
                      <PROPERTY_UNIT_DETAIL>
                      </PROPERTY_UNIT_DETAIL>
                    </PROPERTY_UNIT>
                    <PROPERTY_UNIT>
                      <PROPERTY_UNIT_DETAIL>
                      </PROPERTY_UNIT_DETAIL>
                    </PROPERTY_UNIT>
                    <PROPERTY_UNIT>
                      <PROPERTY_UNIT_DETAIL>
                      </PROPERTY_UNIT_DETAIL>
                    </PROPERTY_UNIT>
                  </PROPERTY_UNITS>
                  <PROPERTY_VALUATIONS>
                    <PROPERTY_VALUATION>
                      <AVMS>
                        <AVM>
                        </AVM>
                      </AVMS>
                      <PROPERTY_VALUATION_DETAIL>
                        <PropertyValuationAmount>805000</PropertyValuationAmount>
                        <PropertyValuationEffectiveDate>2011-06-26</PropertyValuationEffectiveDate>
                      </PROPERTY_VALUATION_DETAIL>
                    </PROPERTY_VALUATION>
                  </PROPERTY_VALUATIONS>
                </PROPERTY>
              </PROPERTIES>
            </COLLATERAL>
          </COLLATERALS>
          <LOANS>
            <COMBINED_LTVS>
              <COMBINED_LTV>
                <CombinedLTVRatioPercent>69</CombinedLTVRatioPercent>
                <HomeEquityCombinedLTVRatioPercent>74</HomeEquityCombinedLTVRatioPercent>
              </COMBINED_LTV>
            </COMBINED_LTVS>
            <LOAN LoanRoleType="SubjectLoan">
              <AMORTIZATION>
                <AMORTIZATION_RULE>
                  <LoanAmortizationPeriodCount>360</LoanAmortizationPeriodCount>
                  <LoanAmortizationPeriodType>Month</LoanAmortizationPeriodType>
                  <LoanAmortizationType>Fixed</LoanAmortizationType>
                </AMORTIZATION_RULE>
              </AMORTIZATION>
              <FORM_SPECIFIC_CONTENTS>
                <FORM_SPECIFIC_CONTENT>
                  <URLA>
                    <URLA_DETAIL>
                    </URLA_DETAIL>
                  </URLA>
                </FORM_SPECIFIC_CONTENT>
              </FORM_SPECIFIC_CONTENTS>
              <GOVERNMENT_LOAN>
              </GOVERNMENT_LOAN>
              <HMDA_LOAN>
                <HMDA_HOEPALoanStatusIndicator>false</HMDA_HOEPALoanStatusIndicator>
              </HMDA_LOAN>
              <INTEREST_CALCULATION>
                <INTEREST_CALCULATION_RULES>
                  <INTEREST_CALCULATION_RULE>
                    <InterestCalculationPeriodType>Month</InterestCalculationPeriodType>
                    <InterestCalculationType>Compound</InterestCalculationType>
                  </INTEREST_CALCULATION_RULE>
                </INTEREST_CALCULATION_RULES>
              </INTEREST_CALCULATION>
              <INVESTOR_LOAN_INFORMATION>
              </INVESTOR_LOAN_INFORMATION>
              <LOAN_DETAIL>
                <AssumabilityIndicator>false</AssumabilityIndicator>
                <BalloonIndicator>false</BalloonIndicator>
                <BorrowerCount>1</BorrowerCount>
                <BuydownTemporarySubsidyIndicator>false</BuydownTemporarySubsidyIndicator>
                <CapitalizedLoanIndicator>false</CapitalizedLoanIndicator>
                <ConstructionLoanIndicator>false</ConstructionLoanIndicator>
                <ConvertibleIndicator>false</ConvertibleIndicator>
                <EscrowIndicator>false</EscrowIndicator>
                <InterestOnlyIndicator>false</InterestOnlyIndicator>
                <LoanAffordableIndicator>false</LoanAffordableIndicator>
                <PrepaymentPenaltyIndicator>false</PrepaymentPenaltyIndicator>
                <RelocationLoanIndicator>false</RelocationLoanIndicator>
                <SharedEquityIndicator>false</SharedEquityIndicator>
              </LOAN_DETAIL>
              <LOAN_LEVEL_CREDIT>
                <LOAN_LEVEL_CREDIT_DETAIL>
                  <LoanLevelCreditScoreValue>771</LoanLevelCreditScoreValue>
                </LOAN_LEVEL_CREDIT_DETAIL>
              </LOAN_LEVEL_CREDIT>
              <LOAN_STATE>
                <LoanStateDate>2011-08-11</LoanStateDate>
                <LoanStateType>AtClosing</LoanStateType>
              </LOAN_STATE>
              <LTV>
                <LTVRatioPercent>43</LTVRatioPercent>
              </LTV>
              <MATURITY>
                <MATURITY_RULE>
                  <LoanMaturityDate>2041-09-01</LoanMaturityDate>
                  <LoanMaturityPeriodCount>360</LoanMaturityPeriodCount>
                  <LoanMaturityPeriodType>Month</LoanMaturityPeriodType>
                </MATURITY_RULE>
              </MATURITY>
              <PAYMENT>
                <PAYMENT_RULE>
                  <InitialPrincipalAndInterestPaymentAmount>1732.86</InitialPrincipalAndInterestPaymentAmount>
                  <PaymentFrequencyType>Monthly</PaymentFrequencyType>
                  <ScheduledFirstPaymentDate>2011-10-01</ScheduledFirstPaymentDate>
                </PAYMENT_RULE>
              </PAYMENT>
              <QUALIFICATION>
                <BorrowerReservesMonthlyPaymentCount>0</BorrowerReservesMonthlyPaymentCount>
                <TotalLiabilitiesMonthlyPaymentAmount>7634</TotalLiabilitiesMonthlyPaymentAmount>
                <TotalMonthlyIncomeAmount>26435</TotalMonthlyIncomeAmount>
                <TotalMonthlyProposedHousingExpenseAmount>3363</TotalMonthlyProposedHousingExpenseAmount>
              </QUALIFICATION>
              <REFINANCE>
                <RefinanceCashOutDeterminationType>LimitedCashOut</RefinanceCashOutDeterminationType>
              </REFINANCE>
              <SELECTED_LOAN_PRODUCT>
                <PRICE_LOCKS>
                  <PRICE_LOCK>
                    <PriceLockDatetime>2011-08-02</PriceLockDatetime>
                  </PRICE_LOCK>
                </PRICE_LOCKS>
              </SELECTED_LOAN_PRODUCT>
              <TERMS_OF_MORTGAGE>
                <LienPriorityType>FirstLien</LienPriorityType>
                <LoanPurposeType>Refinance</LoanPurposeType>
                <MortgageType>Conventional</MortgageType>
                <NoteAmount>342000.00</NoteAmount>
                <NoteDate>2011-08-11</NoteDate>
                <NoteRatePercent>4.5000</NoteRatePercent>
              </TERMS_OF_MORTGAGE>
              <UNDERWRITING>
                <AUTOMATED_UNDERWRITINGS>
                  <AUTOMATED_UNDERWRITING>
                    <AutomatedUnderwritingCaseIdentifier>1040299994</AutomatedUnderwritingCaseIdentifier>
                    <AutomatedUnderwritingRecommendationDescription>ApproveEligible</AutomatedUnderwritingRecommendationDescription>
                    <AutomatedUnderwritingSystemType>DesktopUnderwriter</AutomatedUnderwritingSystemType>
                  </AUTOMATED_UNDERWRITING>
                </AUTOMATED_UNDERWRITINGS>
                <UNDERWRITING_DETAIL>
                  <LoanManualUnderwritingIndicator>false</LoanManualUnderwritingIndicator>
                </UNDERWRITING_DETAIL>
              </UNDERWRITING>
            </LOAN>
            <LOAN LoanRoleType="SubjectLoan">
              <INVESTOR_FEATURES>
                <INVESTOR_FEATURE>
                </INVESTOR_FEATURE>
                <INVESTOR_FEATURE>
                </INVESTOR_FEATURE>
                <INVESTOR_FEATURE>
                </INVESTOR_FEATURE>
                <INVESTOR_FEATURE>
                </INVESTOR_FEATURE>
                <INVESTOR_FEATURE>
                </INVESTOR_FEATURE>
                <INVESTOR_FEATURE>
                </INVESTOR_FEATURE>
              </INVESTOR_FEATURES>
              <INVESTOR_LOAN_INFORMATION>
                <InvestorOwnershipPercent>100</InvestorOwnershipPercent>
                <InvestorRemittanceType>ActualInterestActualPrincipal</InvestorRemittanceType>
              </INVESTOR_LOAN_INFORMATION>
              <LOAN_DETAIL>
                <MortgageModificationIndicator>false</MortgageModificationIndicator>
              </LOAN_DETAIL>
              <LOAN_IDENTIFIERS>
                <LOAN_IDENTIFIER>
                  <InvestorCommitmentIdentifier>455154</InvestorCommitmentIdentifier>
                </LOAN_IDENTIFIER>
                <LOAN_IDENTIFIER>
                  <MERS_MINIdentifier>100880800010049191</MERS_MINIdentifier>
                </LOAN_IDENTIFIER>
                <LOAN_IDENTIFIER>
                  <SellerLoanIdentifier>1004919</SellerLoanIdentifier>
                </LOAN_IDENTIFIER>
              </LOAN_IDENTIFIERS>
              <LOAN_PROGRAMS>
                <LOAN_PROGRAM>
                </LOAN_PROGRAM>
              </LOAN_PROGRAMS>
              <LOAN_STATE>
                <LoanStateDate>2014-06-17</LoanStateDate>
                <LoanStateType>Current</LoanStateType>
              </LOAN_STATE>
              <MI_DATA>
                <MI_DATA_DETAIL>
                  <PrimaryMIAbsenceReasonType>NoMIBasedOnOriginalLTV</PrimaryMIAbsenceReasonType>
                </MI_DATA_DETAIL>
              </MI_DATA>
              <PAYMENT>
                <PAYMENT_SUMMARY>
                  <LastPaidInstallmentDueDate>2011-09-01</LastPaidInstallmentDueDate>
                  <UPBAmount>342000.00</UPBAmount>
                </PAYMENT_SUMMARY>
              </PAYMENT>
              <SELECTED_LOAN_PRODUCT>
                <LOAN_PRODUCT_DETAIL>
                </LOAN_PRODUCT_DETAIL>
              </SELECTED_LOAN_PRODUCT>
              <SERVICING>
                <DELINQUENCY_SUMMARY>
                  <DelinquentPaymentsOverPastTwelveMonthsCount>0</DelinquentPaymentsOverPastTwelveMonthsCount>
                </DELINQUENCY_SUMMARY>
              </SERVICING>
            </LOAN>
          </LOANS>
          <PARTIES>
            <PARTY>
              <ROLES>
                <PARTY_ROLE_IDENTIFIERS>
                  <PARTY_ROLE_IDENTIFIER>
                    <PartyRoleIdentifier>99999398668</PartyRoleIdentifier>
                  </PARTY_ROLE_IDENTIFIER>
                </PARTY_ROLE_IDENTIFIERS>
                <ROLE>
                  <ROLE_DETAIL>
                    <PartyRoleType>DocumentCustodian</PartyRoleType>
                  </ROLE_DETAIL>
                </ROLE>
              </ROLES>
            </PARTY>
            <PARTY>
              <ROLES>
                <PARTY_ROLE_IDENTIFIERS>
                  <PARTY_ROLE_IDENTIFIER>
                    <PartyRoleIdentifier>144564</PartyRoleIdentifier>
                  </PARTY_ROLE_IDENTIFIER>
                </PARTY_ROLE_IDENTIFIERS>
                <ROLE>
                  <LOAN_ORIGINATOR>
                    <LoanOriginatorType>Lender</LoanOriginatorType>
                  </LOAN_ORIGINATOR>
                  <ROLE_DETAIL>
                    <PartyRoleType>LoanOriginator</PartyRoleType>
                  </ROLE_DETAIL>
                </ROLE>
              </ROLES>
            </PARTY>
            <PARTY>
              <ROLES>
                <PARTY_ROLE_IDENTIFIERS>
                  <PARTY_ROLE_IDENTIFIER>
                    <PartyRoleIdentifier>272190003</PartyRoleIdentifier>
                  </PARTY_ROLE_IDENTIFIER>
                </PARTY_ROLE_IDENTIFIERS>
                <ROLE>
                  <ROLE_DETAIL>
                    <PartyRoleType>LoanSeller</PartyRoleType>
                  </ROLE_DETAIL>
                </ROLE>
              </ROLES>
            </PARTY>
            <PARTY>
              <LEGAL_ENTITY>
                <LEGAL_ENTITY_DETAIL>
                  <FullName>Cole Taylor Bank</FullName>
                </LEGAL_ENTITY_DETAIL>
              </LEGAL_ENTITY>
              <ROLES>
                <ROLE>
                  <ROLE_DETAIL>
                    <PartyRoleType>NotePayTo</PartyRoleType>
                  </ROLE_DETAIL>
                </ROLE>
              </ROLES>
            </PARTY>
            <PARTY>
              <ROLES>
                <PARTY_ROLE_IDENTIFIERS>
                  <PARTY_ROLE_IDENTIFIER>
                    <PartyRoleIdentifier>002003402</PartyRoleIdentifier>
                  </PARTY_ROLE_IDENTIFIER>
                </PARTY_ROLE_IDENTIFIERS>
                <ROLE>
                  <ROLE_DETAIL>
                    <PartyRoleType>Payee</PartyRoleType>
                  </ROLE_DETAIL>
                </ROLE>
              </ROLES>
            </PARTY>
            <PARTY>
              <ROLES>
                <PARTY_ROLE_IDENTIFIERS>
                  <PARTY_ROLE_IDENTIFIER>
                    <PartyRoleIdentifier>272190003</PartyRoleIdentifier>
                  </PARTY_ROLE_IDENTIFIER>
                </PARTY_ROLE_IDENTIFIERS>
                <ROLE>
                  <ROLE_DETAIL>
                    <PartyRoleType>Servicer</PartyRoleType>
                  </ROLE_DETAIL>
                </ROLE>
              </ROLES>
            </PARTY>
          </PARTIES>
        </DEAL>
      </DEALS>
      <PARTIES>
        <PARTY>
          <ROLES>
            <PARTY_ROLE_IDENTIFIERS>
              <PARTY_ROLE_IDENTIFIER>
                <PartyRoleIdentifier>99999398668</PartyRoleIdentifier>
              </PARTY_ROLE_IDENTIFIER>
            </PARTY_ROLE_IDENTIFIERS>
            <ROLE>
              <ROLE_DETAIL>
                <PartyRoleType>DocumentCustodian</PartyRoleType>
              </ROLE_DETAIL>
            </ROLE>
          </ROLES>
        </PARTY>
        <PARTY>
          <ROLES>
            <PARTY_ROLE_IDENTIFIERS>
              <PARTY_ROLE_IDENTIFIER>
                <PartyRoleIdentifier>272190003</PartyRoleIdentifier>
              </PARTY_ROLE_IDENTIFIER>
            </PARTY_ROLE_IDENTIFIERS>
            <ROLE>
              <ROLE_DETAIL>
                <PartyRoleType>LoanSeller</PartyRoleType>
              </ROLE_DETAIL>
            </ROLE>
          </ROLES>
        </PARTY>
        <PARTY>
          <ROLES>
            <PARTY_ROLE_IDENTIFIERS>
              <PARTY_ROLE_IDENTIFIER>
                <PartyRoleIdentifier>272190003</PartyRoleIdentifier>
              </PARTY_ROLE_IDENTIFIER>
            </PARTY_ROLE_IDENTIFIERS>
            <ROLE>
              <ROLE_DETAIL>
                <PartyRoleType>Servicer</PartyRoleType>
              </ROLE_DETAIL>
            </ROLE>
          </ROLES>
        </PARTY>
      </PARTIES>
    </DEAL_SET>
    <PARTIES>
      <PARTY>
        <ROLES>
          <PARTY_ROLE_IDENTIFIERS>
            <PARTY_ROLE_IDENTIFIER>
              <PartyRoleIdentifier>VASIAA01D</PartyRoleIdentifier>
            </PARTY_ROLE_IDENTIFIER>
          </PARTY_ROLE_IDENTIFIERS>
          <ROLE>
            <ROLE_DETAIL>
              <PartyRoleType>LoanDeliveryFilePreparer</PartyRoleType>
            </ROLE_DETAIL>
          </ROLE>
        </ROLES>
      </PARTY>
    </PARTIES>
  </DEAL_SETS>
</MESSAGE>
      eos

    end
  end

end
