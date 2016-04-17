class Smds::FnmaLoan < DatabaseDatamartReadonly
  self.table_name_prefix += 'smds_' unless self.table_name_prefix.include?('smds')

  def self.primary_key
    'SellerLoanIdentifier'
  end

  belongs_to :master_loan, class_name: 'Master::Loan', foreign_key: 'SellerLoanIdentifier', primary_key: 'loan_num'
  has_many :liabilities, through: :master_loan
  has_many :master_borrowers, through: :master_loan, source: :borrowers
  belongs_to :loan_general, foreign_key: 'SellerLoanIdentifier', primary_key: :loan_id
  has_one :transaction_detail, through: :loan_general
  delegate :number_of_financed_properties, to: :loan_general, allow_nil: true
  belongs_to :compass_loan_detail, :class_name => 'Smds::CompassLoanDetail', foreign_key: 'SellerLoanIdentifier', primary_key: :loan_number
  delegate :AssumabilityIndicator, to: :compass_loan_detail, allow_nil: true

  SELECT_CLAUSE_SQL = <<-eos
    SELECT  CASE WHEN PropertyStreetAddress <> 'NA' THEN SUBSTRING(PropertyStreetAddress, 1, 100)
          ELSE '' END AS [AddressLineText1],
        CASE WHEN PropertyCity <> 'NA' THEN SUBSTRING(PropertyCity, 1, 50)
          ELSE '' END AS [CityName1],
        CASE WHEN PropertyPostalCode <> 'NA' THEN SUBSTRING(PropertyPostalCode, 1, 9)
          ELSE '' END AS [PostalCode1],
        CASE WHEN PropertyState <> 'NA' THEN SUBSTRING(PropertyState, 1, 2)
          ELSE '' END AS [StateCode1],
        CASE LoanType WHEN 'Conventional' THEN
            CASE WHEN PropertyType IN('Attached', 'Detached') THEN 'G'
              ELSE CASE WHEN UPPER(ProjectType) LIKE '%PUD%' THEN
                  CASE ProjectType
                    WHEN 'E_PUD' THEN 'E'
                    WHEN 'F_PUD' THEN 'F'
                    ELSE '' END
                ELSE CASE WHEN UPPER(ProjectType) LIKE '%CONDO%' THEN
                    CASE ProjectType
                      WHEN 'PCondominium' THEN 'P'
                      WHEN 'QCondominium' THEN 'Q'
                      WHEN 'RCondominium' THEN 'R'
                      WHEN 'SCondominium' THEN 'S'
                      WHEN 'TCondominium' THEN 'T'
                      WHEN 'UCondominium' THEN 'U'
                      WHEN 'VCondominium' THEN 'V'
                      ELSE '' END
                  ELSE '' END END END
          ELSE '' END AS [ProjectClassificationIdentifier],
        CASE WHEN UPPER(PropertyType) LIKE '%CONDO%'
              AND SUBSTRING(ProjectType, 1, 1) IN('P','Q','R','S','T','U','V')
              AND ProjectName <> 'NA'
            THEN SUBSTRING(ProjectName, 1, 50)
          ELSE '' END AS [ProjectName],
        CASE WHEN PropertyValMethod = 'AutomatedValuationModel' THEN
            CASE WHEN AVMModelName IN('AutomatedPropertyService', 'Casa', 'FidelityHansen', 'HomePriceAnalyzer', 'HomePriceIndex',
                  'HomeValueExplorer', 'Indicator', 'NetValue', 'Other', 'Pass', 'PropertySurveyAnalysisReport', 'ValueFinder',
                  'ValuePoint', 'ValuePoint4', 'ValuePointPlus', 'ValueSure', 'ValueWizard', 'ValueWizardPlus', 'VeroIndexPlus',
                  'VeroValue')
                THEN AVMModelName
              ELSE '' END
          ELSE '' END AS [AVMModelNameType],
        CASE WHEN PropertyValMethod IN('DriveBy', 'FullAppraisal', 'PriorAppraisalUsed')
              AND AppraisalDocID <> 'NA'
            THEN SUBSTRING(AppraisalDocID, 1, 20)
          ELSE '' END AS [AppraisalIdentifier],
        CASE WHEN AppraisdValue > 0 THEN STR(AppraisdValue, 9, 0)
          ELSE '' END AS [PropertyValuationAmount],
        CASE WHEN CONVERT(varchar, AppraisalDt, 101) <> '01/01/1900' THEN SUBSTRING(CONVERT(varchar, AppraisalDt, 120), 1, 10)
          ELSE '' END AS [PropertyValuationEffectiveDate],
        CASE WHEN PropertyValMethod IN('AutomatedValuationModel', 'DesktopAppraisal', 'DriveBy', 'FullAppraisal', 'None', 'PriorAppraisalUsed')
            THEN PropertyValMethod
          ELSE '' END AS [PropertyValuationMethodType],
        CASE WHEN CLTV > 0 THEN STR(CEILING(CLTV), 3, 0)
          ELSE '' END AS [CombinedLTVRatioPercent],
        CASE WHEN HCLTV > 0 THEN
            CASE WHEN HCLTV < CLTV THEN STR(CEILING(CLTV), 3, 0) ELSE STR(CEILING(HCLTV), 3, 0) END
          ELSE '' END AS [HomeEquityCombinedLTVRatioPercent],
        CASE WHEN LnAmortTerm > 0 THEN STR(LnAmortTerm, 3, 0)
          ELSE '' END AS [LoanAmortizationPeriodCount],
        'Month' AS [LoanAmortizationPeriodType],
        CASE WHEN LnPurpose = 'Purchase' AND LienPriority = 'FirstLien' AND SalePrice > 0 THEN STR(SalePrice, 9, 0)
          ELSE '' END AS [PurchasePriceAmount],
        CASE WHEN LoanType = 'FHA' AND FHASectionAct <> 'NA' THEN FHASectionAct
          ELSE '' END AS [SectionOfActType],
        CASE WHEN HOEPA = 'Y' THEN 'true'
          ELSE 'false' END AS [HMDA_HOEPALoanStatusIndicator],
        'Month' AS [InterestCalculationPeriodType],
        'Compound' AS [InterestCalculationType],
        CASE WHEN CONVERT(varchar, LnAppRecdDt, 101) <> '01/01/1900' THEN SUBSTRING(CONVERT(varchar, LnAppRecdDt, 120), 1, 10)
          ELSE '' END AS [ApplicationReceivedDate],
        'false' AS [CapitalizedLoanIndicator],
        CASE WHEN LnPurpose IN('ConstructionOnly', 'ConstructionToPermanent') THEN 'true'
          ELSE 'false' END AS [ConstructionLoanIndicator],
        CASE WHEN CONVERT(varchar, NoteDt, 101) <> '01/01/1900' THEN SUBSTRING(CONVERT(varchar, NoteDt, 120), 1, 10)
          ELSE '' END AS [LoanStateDate1],
        CASE WHEN BaseLTV > 0 THEN STR(CEILING(BaseLTV), 3, 0)
          ELSE '' END AS [BaseLTVRatioPercent],
        CASE WHEN LTV > 0 THEN STR(CEILING(LTV), 3, 0)
          ELSE '' END AS [LTVRatioPercent],
        CASE WHEN CONVERT(varchar, MaturityDt, 101) <> '01/01/1900' THEN SUBSTRING(CONVERT(varchar, MaturityDt, 120), 1, 10)
          ELSE '' END AS [LoanMaturityDate],
        CASE WHEN LnMaturityTerm > 0 THEN STR(LnMaturityTerm, 3, 0)
          ELSE '' END AS [LoanMaturityPeriodCount],
        'Month' AS [LoanMaturityPeriodType],
        CASE WHEN [PI] > 0 THEN STR([PI], 10, 2)
          ELSE '' END AS [InitialPrincipalAndInterestPaymentAmount],
        'Monthly' AS [PaymentFrequencyType],
        CASE WHEN CONVERT(varchar, FirstPmtDt, 101) <> '01/01/1900' THEN SUBSTRING(CONVERT(varchar, FirstPmtDt, 120), 1, 10)
          ELSE '' END AS [ScheduledFirstPaymentDate],
        CASE WHEN MonthlyDebtExp > 0 THEN STR(MonthlyDebtExp, 9, 0)
          ELSE '' END AS [TotalLiabilitiesMonthlyPaymentAmount],
        CASE WHEN MonthlyIncome > 0 THEN STR(MonthlyIncome, 9, 0)
          ELSE '' END AS [TotalMonthlyIncomeAmount],
        CASE WHEN MonthlyHsingExp > 0 THEN STR(MonthlyHsingExp, 9, 0)
          ELSE '' END AS [TotalMonthlyProposedHousingExpenseAmount],
        CASE WHEN LnPurpose = 'Refinance' AND RefPurposeType <> 'NA' THEN
            CASE RefPurposeType
              WHEN 'CashOutDebtConsolidation' THEN 'CashOut'
              WHEN 'CashOutHomeImprovement' THEN 'CashOut'
              WHEN 'CashOutOther' THEN 'CashOut'
              WHEN 'CashOutLimited' THEN 'LimitedCashOut'
              WHEN 'ChangeInRateTerm' THEN
                CASE WHEN LoanType = 'Conventional' THEN 'LimitedCashOut'
                  ELSE 'NoCashOut' END
              WHEN 'NoCashOutFHAStreamlinedRefinance' THEN 'NoCashOut'
              WHEN 'VAStreamlinedRefinance' THEN 'NoCashOut'
              ELSE '' END
          ELSE '' END AS [RefinanceCashOutDeterminationType],
        CASE WHEN CONVERT(varchar, RlcDate, 101) <> '01/01/1900' THEN SUBSTRING(CONVERT(varchar, RlcDate, 120), 1, 10)
          ELSE '' END AS [PriceLockDatetime],
        CASE WHEN LoanType IN ('Conventional', 'FHA', 'VA') THEN LoanType
          ELSE CASE WHEN LoanType = 'FarmersHomeAdministration' THEN 'USDARuralHousing'
            ELSE '' END END AS [MortgageType1],
        CASE WHEN LnAmt > 0 THEN STR(LnAmt, 12, 2)
          ELSE '' END AS [NoteAmount],
        CASE WHEN CONVERT(varchar, NoteDt, 101) <> '01/01/1900' THEN SUBSTRING(CONVERT(varchar, NoteDt, 120), 1, 10)
          ELSE '' END AS [NoteDate],
        CASE WHEN FinalNoteRate > 0 THEN STR(FinalNoteRate, 8, 4)
          ELSE '' END AS [NoteRatePercent],
        '100' AS [InvestorOwnershipPercent],
        CASE WHEN InvestorName = 'Fannie Mae - MBS' AND SUBSTRING(InvestorCommitNbr, 1, 2) = 'ME' THEN '18'
          ELSE '' END AS [InvestorRemittanceDay],
        CASE InvestorName
          WHEN 'Fannie Mae - MBS' THEN
            CASE WHEN SUBSTRING(InvestorCommitNbr, 1, 2) = 'ME' THEN 'ScheduledInterestScheduledPrincipal'
              ELSE '' END
          WHEN 'Fannie Mae' THEN
            CASE WHEN SUBSTRING(InvestorCommitNbr, 1, 2) = 'FN' THEN 'ActualInterestActualPrincipal'
              ELSE '' END
          ELSE '' END AS [InvestorRemittanceType],
        'false' AS [MortgageModificationIndicator],
        CASE WHEN InvestorName = 'Fannie Mae' AND SUBSTRING(InvestorCommitNbr, 1, 2) = 'FN' THEN SUBSTRING(InvestorCommitNbr, 3, 28)
          ELSE '' END AS [InvestorCommitmentIdentifier],
        CASE WHEN InvestorName = 'Fannie Mae - MBS' AND SUBSTRING(InvestorCommitNbr, 1, 2) = 'ME' THEN SUBSTRING(InvestorCommitNbr, 3, 28)
          ELSE '' END AS [InvestorContractIdentifier],
        CASE WHEN MERS <> 'NA' THEN SUBSTRING(MERS, 1, 30)
          ELSE '' END AS [MERS_MINIdentifier],
        CASE WHEN LnNbr <> 'NA' THEN SUBSTRING(LnNbr, 1, 30)
          ELSE '' END AS [SellerLoanIdentifier],
        CASE WHEN LnPurpose = 'Purchase' AND PropertyOccupy = 'PrimaryResidence' THEN
            CASE WHEN FirstTimeHomebuyer = 'Y' THEN 'LoanFirstTimeHomebuyer'
              ELSE '' END
          ELSE '' END AS [LoanProgramIdentifier],
        CASE WHEN InvestorName = 'Fannie Mae - MBS' AND SUBSTRING(InvestorCommitNbr, 1, 2) = 'ME' AND ISNULL(CalcAggregateLoanCurtailments, 0) > 0
            THEN STR(CalcAggregateLoanCurtailments, 11, 2)
          ELSE '' END AS [AggregateLoanCurtailmentAmount],
        CASE WHEN CONVERT(varchar, IntPaidThruDt, 101) <> '01/01/1900' THEN SUBSTRING(CONVERT(varchar, IntPaidThruDt, 120), 1, 10)
          ELSE '' END AS [LastPaidInstallmentDueDate],
        CASE WHEN UPB > 0 THEN STR(UPB, 12, 2)
          ELSE '' END AS [UPBAmount1],
        CASE WHEN ProductCode LIKE '%RP%' THEN 'DURefiPlus'
          ELSE '' END AS [RefinanceProgramIdentifier],
        '0' AS [DelinquentPaymentsOverPastTwelveMonthsCount],
        CASE WHEN PropertyValMethod IN('DriveBy', 'FullAppraisal', 'PriorAppraisalUsed') THEN
            CASE WHEN AppraiserLicenseNbr <> 'NA' THEN SUBSTRING(AppraiserLicenseNbr, 1, 21)
              ELSE '' END
          ELSE '' END AS [AppraiserLicenseIdentifier],
        CASE WHEN PropertyValMethod IN('DriveBy', 'FullAppraisal', 'PriorAppraisalUsed') THEN
            CASE WHEN SuperAppraiserLicenceNbr <> 'NA' THEN SUBSTRING(SuperAppraiserLicenceNbr, 1, 21)
              ELSE '' END
          ELSE '' END AS [AppraiserSupervisorLicenseIdentifier],
        isNull(AttachmentType, '') AS [AttachmentType], 
        LnAmortType,
        LienPriority,
        LnPurpose,
        LoanType,
        LTV,
        CurrLTV,
        ProductCode,
        AUSKey,
        AUSRecommendation,
        ARMConvertibility,
        AffordableLoanFlag,
        PrepayPenaltyFlg,
        InterestOnlyFlg,
        EscrowWaiverFlg,
        RelocationLoanFlag,
        SharedEquityFlag,
        InvestorName,
        InvestorCommitNbr,
        InvestorCollateralPrgm,
        ProjectType,
        PropertyOccupy,
        NbrOfUnits,
        NbrOfBedroomUnit1,
        NbrOfBedroomUnit2,
        NbrOfBedroomUnit3,
        NbrOfBedroomUnit4,
        CondoProjStatusType,
        CondoProjAttachType,
        CondoProjDesignType,
        CondoProjTotalUnits,
        CondoProjUnitsSold,
        CalcSoldScheduledBal,
        DifferentPropertyAddress,
        Brw1CreditScoreSource,
        Brw1CreditScore,
        Brw1FirstTimeHomebuyer,
        Brw2CreditScoreSource,
        Brw2CreditScore,
        Brw2FirstTimeHomebuyer,
        Brw3CreditScore,
        Brw3FirstTimeHomebuyer,
        Brw4CreditScore,
        Brw4FirstTimeHomebuyer,
        MailingStreetAddress,
        MailingCity,
        MailingPostalCode,
        MailingState,
        USAddress,
        FIPSCode,
        HPMLFlg,
        Bankruptcy,
        FirstTimeHomebuyer,
        Foreclosure,
        PropertyType,
        PropertyCounty,
        SelfEmpFlg,
        Brw1SelfEmpFlg,
        Brw2SelfEmpFlg,
        Brw3SelfEmpFlg,
        Brw4SelfEmpFlg,
        APRSprdPct,
        MICertNbr,
        AUSType,
        EligibleRentUnit1,
        EligibleRentUnit2,
        EligibleRentUnit3,
        EligibleRentUnit4,
        CntSFC,
        StringSFC,
        NbrFinancedProperties,
        SpecialFloodHazardArea,
        TitleRights,
        ConstructionType,
        YearBuilt,
        NbrOfBrw,
        BalloonFlg,
        BuydownFlg,
        MICompanyName,
        MiCoveragePct,
        LenderMIPaidRtPct,
        FinancedMIAmt,
        LenderPaidMiFlg,
        BorrowerPdDiscPtsTotalAmt,
        NbrMonthsReserves,
        CashOutAmt,
        FieldworkObtained,
        PropertyValMethod,
        AVMModelName,
        LnAmortTerm,
        CASE WHEN InvestorName = 'Fannie Mae - MBS' AND SUBSTRING(InvestorCommitNbr, 1, 2) = 'ME' THEN '20000398668'
          ELSE CASE WHEN InvestorName = 'Fannie Mae' AND SUBSTRING(InvestorCommitNbr, 1, 2) = 'FN' THEN '99999398668'
            ELSE '' END END AS [document_custodian],
        CASE WHEN LnOrigCompanyId <> 'NA' THEN SUBSTRING(LnOrigCompanyId, 1, 50)
          ELSE '' END AS [LoanOriginationCompanyIdentifier],
        CASE WHEN LnOriginatorId <> 'NA' THEN SUBSTRING(LnOriginatorId, 1, 50)
          ELSE '' END AS [LoanOriginatorIdentifier],
        CASE SUBSTRING(LendingChannel, 1, 2)
          WHEN 'W0' THEN 'Broker'
          WHEN 'A0' THEN 'Lender'
          WHEN 'R0' THEN 'Correspondent'
          ELSE '' END AS [LoanOriginatorType],
        '272190003' AS [servicer_number],
        CASE WHEN SUBSTRING(LendingChannel, 1, 2) = 'R0' THEN SUBSTRING(InstitutionName, 1, 100)
          ELSE 'Cole Taylor Bank' END AS [FullName],
        FirstRateChgDt as [FirstRateChgDt],
        MarginPct AS [MarginRatePercent],
        InitialCap AS [FirstMaximumRateChangePercent],
        IntervalCap AS [SubsequentMaximumRateChangePercent],
        InitialARMLockoutTerm AS [FirstPerChangeRateAdjustmentFrequencyMonthsCount],
        SubseqARMLockoutTerm AS [SubsequentPerChangeRateAdjustmentFrequencyMonthsCount],
        IndexCurrValPct AS [DisclosedIndexRatePercent],
        [RepresentativeFICO]
     FROM smds.SMDSCompassLoanDetails
  eos

  WHERE_CLAUSE_SQL = <<-eos
    WHERE (InvestorName = 'Fannie Mae' AND SUBSTRING(InvestorCommitNbr, 1, 2) = 'FN')
       OR (InvestorName = 'Fannie Mae - MBS' AND SUBSTRING(InvestorCommitNbr, 1, 2) = 'ME')
  eos

  CREATE_VIEW_SQL = SELECT_CLAUSE_SQL + "\n" + WHERE_CLAUSE_SQL

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  include Smds::DeliveryModelMethods

  include Smds::DataCleanupMethods

  include Smds::UlddMethods

  def delivery_type
    "FNMA"
  end

  def valuation
    @valuation ||= Fhlmc::ValuationType.new(self)
  end

  def PropertyValuationFormType
    valuation.valuation_form
  end

  def LoanAffordableIndicator
    return true if home_ready?
    super
  end

  def home_ready?
    self.ProductCode.in?(['C10/1ARM LIB HR','C15FXD HR','C20FXD HR','C30FXD HR','C5/1ARM LIB HR','C7/1ARM LIB HR'])
  end

  def LoanAcquisitionScheduledUPBAmount
    if check_fannie_mae && self.CalcSoldScheduledBal.to_f > 0
      self.CalcSoldScheduledBal.round(2)
    else
      ''
    end
  end

  def LoanDefaultLossPartyType
    if check_fannie_mae
      'Investor'
    else
      ''
    end
  end

  def REOMarketingPartyType
    if check_fannie_mae
      return 'Investor'
    end
    ''
  end

  def BorrowerPaidDiscountPointsTotalAmount
    return 0 if self.BorrowerPdDiscPtsTotalAmt.to_f < 0
    self.BorrowerPdDiscPtsTotalAmt
  end

  def TotalMortgagedPropertiesCount
    self.NbrFinancedProperties
  end

  def BorrowerReservesMonthlyPaymentCount
    count = self.NbrMonthsReserves.to_i
    (count > 999) ? 999 : count
  end

  def RefinanceCashOutAmount
    return unless self.LnPurpose == 'Refinance'
    format_num self.CashOutAmt, 2
  end

  def check_fannie_mae
    self.InvestorName == 'Fannie Mae - MBS' && self.InvestorCommitNbr.start_with?('ME')
  end

  def pool_id
    commitment_id = self.InvestorCommitmentIdentifier
    if commitment_id.present?
      "FN#{commitment_id}"
    else
      "ME#{self.InvestorContractIdentifier}"
    end
  end
end

unless defined?(FnmaLoan)
  FnmaLoan = Smds::FnmaLoan #Rails can't make up it's mind about which one it is looking for.
end
