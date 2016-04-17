require 'uldd/fhlmc/valuation_type'

class Smds::FhlmcLoan < DatabaseDatamartReadonly
  self.table_name_prefix += 'smds_' unless self.table_name_prefix.include?('smds')

  def self.primary_key
    'SellerLoanIdentifier'
  end

  CREATE_VIEW_SQL = <<-eos
      SELECT cld.[LnNbr]
      ,cld.[LendingChannel]
      ,cld.[InstitutionName]
      ,cld.[LoanOfficer]
      ,cld.[ProductCode]
      ,cld.[ProductDesc]
      ,cld.[InnovProdCode]
      ,cld.[LnProcessStatus]
      ,cld.[LnPipelineStatus]
      ,cld.[RtShtNbr]
      ,cld.[InitialRlcPerformedDt]
      ,cld.[RlcPerformedDt]
      ,cld.[RlcDate]
      ,cld.[RlcPeriod]
      ,cld.[RlcExpireDt]
      ,cld.[RlcConfirmCode]
      ,cld.[RlcStatus]
      ,cld.[FinalNoteRate]
      ,cld.[GrossBuyPrice]
      ,cld.[NetLockPrice]
      ,cld.[OriginatorCompensation]
      ,cld.[NetBuyPrice]
      ,cld.[BaseLnAmt]
      ,cld.[LnAmt]
      ,cld.[UPB]
      ,cld.[UPBSource]
      ,cld.[CompassUPB]
      ,cld.[SoldScheduledBal]
      ,cld.[CalcUPB]
      ,cld.[CalcSoldScheduledBal]
      ,cld.[CalcAggregateLoanCurtailments]
      ,cld.[SubordinateFinance]
      ,cld.[MaxHELOCAmt]
      ,cld.[UndrawnHELOCAmt]
      ,cld.[CashOutAmt]
      ,cld.[DownPmtAmt]
      ,cld.[DownPmtType]
      ,cld.[BorrowerPdDiscPtsTotalAmt]
      ,cld.[PI]
      ,cld.[TI]
      ,cld.[LnPurpose]
      ,cld.[RefPurposeType]
      ,cld.[LTV]
      ,cld.[CLTV]
      ,cld.[HCLTV]
      ,cld.[BaseLTV]
      ,cld.[CurrLTV]
      ,cld.[CurrCLTV]
      ,cld.[CurrHCLTV]
      ,cld.[PropertyOccupy]
      ,cld.[NewCnstr]
      ,cld.[BldgStatusType]
      ,cld.[PropertyStreetAddressNbr]
      ,cld.[PropertyStreetAddressName]
      ,cld.[PropertyStreetAddressUnit]
      ,cld.[PropertyStreetAddress]
      ,cld.[PropertyCity]
      ,cld.[PropertyState]
      ,cld.[PropertyCounty]
      ,cld.[PropertyPostalCode]
      ,cld.[PropertyType]
      ,cld.[RlcPropType]
      ,cld.[ProjectType]
      ,cld.[ProjectName]
      ,cld.[NbrOfUnits]
      ,cld.[NbrOfStories]
      ,cld.[AppraisalDocID]
      ,cld.[AppraisalDt]
      ,cld.[AppraisdValue]
      ,cld.[SalePrice]
      ,cld.[BuydownFlg]
      ,cld.[BuydownType]
      ,cld.[LoanType]
      ,cld.[LienPriority]
      ,cld.[LnDocType]
      ,cld.[LnAmortType]
      ,cld.[LnAmortTerm]
      ,cld.[LnMaturityTerm]
      ,cld.[LnRemainingTerm]
      ,cld.[InterestOnlyFlg]
      ,cld.[EscrowWaiverFlg]
      ,cld.[EscrowWaiverType]
      ,cld.[PrepayPenaltyFlg]
      ,cld.[LenderPaidMiFlg]
      ,cld.[PlanCode]
      ,cld.[IndexType]
      ,cld.[IndexCurrValPct]
      ,cld.[MarginPct]
      ,cld.[InitialARMLockoutTerm]
      ,cld.[SubseqARMLockoutTerm]
      ,cld.[InitialCap]
      ,cld.[IntervalCap]
      ,cld.[LifetimeCap]
      ,cld.[LifetimeFloor]
      ,cld.[PmtAdjLifeCapAmt]
      ,cld.[LifeTimeCapRt]
      ,cld.[ARMConvertibility]
      ,cld.[InterestOnlyTerm]
      ,cld.[InterestOnlyEndDt]
      ,cld.[Assumable]
      ,cld.[BalloonFlg]
      ,cld.[BalloonTerm]
      ,cld.[BalloonEndDt]
      ,cld.[FHASectionAct]
      ,cld.[FirstRateChgDt]
      ,cld.[FirstPmtChgDt]
      ,cld.[FirstPmtDt]
      ,cld.[NextPmtDt]
      ,cld.[MaturityDt]
      ,cld.[HUD801OrigFee]
      ,cld.[HUD801PaidBy]
      ,cld.[HUD802DiscFee]
      ,cld.[HUD802PaidBy]
      ,cld.[HUD809VAFundingFeeAmt]
      ,cld.[HUD813AdminFee]
      ,cld.[HUD901IntDueAtClsg]
      ,cld.[HUD902MIPAmt]
      ,cld.[HUD902MIPRate]
      ,cld.[HUD1001InitialEscrwDeposit]
      ,cld.[HUD1002HzrdInsurance]
      ,cld.[HUD1002NbrOfMths]
      ,cld.[HUD1003MtgInsurance]
      ,cld.[HUD1003NbrOfMths]
      ,cld.[HUD1004CityPrptyTax]
      ,cld.[HUD1004NbrOfMths]
      ,cld.[HUD1005CountyPrptyTax]
      ,cld.[HUD1005NbrOfMths]
      ,cld.[HUD1006Assessments]
      ,cld.[HUD1006NbrOfMths]
      ,cld.[HUD1007FloodInsurance]
      ,cld.[HUD1007NbrOfMths]
      ,cld.[HUD1008Other1]
      ,cld.[HUD1008NbrOfMths]
      ,cld.[HUD1008FeeName]
      ,cld.[HUD1009Other2]
      ,cld.[HUD1009NbrOfMths]
      ,cld.[HUD1009FeeName]
      ,cld.[HUD1010AggregateAdj]
      ,cld.[HUDCurtailment]
      ,cld.[EscrowAcctPmtsIn]
      ,cld.[EscrowAcctPmtsOut]
      ,cld.[EscrowAcctBal]
      ,cld.[CurrEscrowBal]
      ,cld.[PrinPdYTD]
      ,cld.[IntPdYTD]
      ,cld.[TaxPdYTD]
      ,cld.[NextTaxDueDt]
      ,cld.[MIPmtAmt]
      ,cld.[MiCoveragePct]
      ,cld.[MICompanyName]
      ,cld.[MICertNbr]
      ,cld.[MIPmtFreq]
      ,cld.[MIPmtNextDueDt]
      ,cld.[FloodZoneId]
      ,cld.[FloodCommunityId]
      ,cld.[FloodCommunityParticipation]
      ,cld.[FloodMapId]
      ,cld.[FloodMapPanelDt]
      ,cld.[FloodCertId]
      ,cld.[FloodDeterminationDt]
      ,cld.[FloodCompany]
      ,cld.[SpecialFloodHazardArea]
      ,cld.[FIPSCode]
      ,cld.[FirstTimeHomebuyer]
      ,cld.[ForeignNational]
      ,cld.[Foreclosure]
      ,cld.[Bankruptcy]
      ,cld.[RepresentativeFICO]
      ,cld.[SelfEmpFlg]
      ,cld.[BusinessPhoneNbr]
      ,cld.[EmployeeLoanFlg]
      ,cld.[MonthlyDebtExp]
      ,cld.[MonthlyHsingExp]
      ,cld.[MonthlyOtherExp]
      ,cld.[MonthlyIncome]
      ,cld.[MonthlyIncomeBase]
      ,cld.[MonthlyIncomeOther]
      ,cld.[DTI]
      ,cld.[HsingExpRatio]
      ,cld.[OtherExpRatio]
      ,cld.[VerifiedAssetsMktVal]
      ,cld.[NbrOfBrw]
      ,cld.[Brw1LName]
      ,cld.[Brw1FName]
      ,cld.[Brw1MI]
      ,cld.[Brw1Suffix]
      ,cld.[Brw1SSN]
      ,cld.[Brw1CreditScore]
      ,cld.[Brw1CreditScoreSource]
      ,cld.[Brw1CreditScoreIssued]
      ,cld.[Brw1DOB]
      ,cld.[Brw1Age]
      ,cld.[Brw1Gender]
      ,cld.[Brw1Race1]
      ,cld.[Brw1Race2]
      ,cld.[Brw1Race3]
      ,cld.[Brw1Race4]
      ,cld.[Brw1Race5]
      ,cld.[Brw1Ethnicity]
      ,cld.[Brw1OptedOutHMDA]
      ,cld.[Brw1HomePhone]
      ,cld.[Brw1MonthlyIncome]
      ,cld.[Brw1MonthlyIncomeBase]
      ,cld.[Brw1MonthlyIncomeOther]
      ,cld.[Brw1AssetsMktVal]
      ,cld.[Brw1Employer]
      ,cld.[Brw1MonthsEmployed]
      ,cld.[Brw1SelfEmpFlg]
      ,cld.[Brw1MthsAtCurrAddr]
      ,cld.[Brw1FirstTimeHomebuyer]
      ,cld.[Brw1CitizenshipResidency]
      ,cld.[Brw2LName]
      ,cld.[Brw2FName]
      ,cld.[Brw2MI]
      ,cld.[Brw2Suffix]
      ,cld.[Brw2SSN]
      ,cld.[Brw2CreditScore]
      ,cld.[Brw2CreditScoreSource]
      ,cld.[Brw2CreditScoreIssued]
      ,cld.[Brw2DOB]
      ,cld.[Brw2Age]
      ,cld.[Brw2Gender]
      ,cld.[Brw2Race1]
      ,cld.[Brw2Race2]
      ,cld.[Brw2Race3]
      ,cld.[Brw2Race4]
      ,cld.[Brw2Race5]
      ,cld.[Brw2Ethnicity]
      ,cld.[Brw2OptedOutHMDA]
      ,cld.[Brw2HomePhone]
      ,cld.[Brw2MonthlyIncome]
      ,cld.[Brw2MonthlyIncomeBase]
      ,cld.[Brw2MonthlyIncomeOther]
      ,cld.[Brw2AssetsMktVal]
      ,cld.[Brw2Employer]
      ,cld.[Brw2MonthsEmployed]
      ,cld.[Brw2SelfEmpFlg]
      ,cld.[Brw2MthsAtCurrAddr]
      ,cld.[Brw2FirstTimeHomebuyer]
      ,cld.[Brw2CitizenshipResidency]
      ,cld.[Brw3LName]
      ,cld.[Brw3FName]
      ,cld.[Brw3MI]
      ,cld.[Brw3Suffix]
      ,cld.[Brw3SSN]
      ,cld.[Brw3CreditScore]
      ,cld.[Brw3DOB]
      ,cld.[Brw3Age]
      ,cld.[Brw3Gender]
      ,cld.[Brw3Race1]
      ,cld.[Brw3Race2]
      ,cld.[Brw3Race3]
      ,cld.[Brw3Race4]
      ,cld.[Brw3Race5]
      ,cld.[Brw3Ethnicity]
      ,cld.[Brw3OptedOutHMDA]
      ,cld.[Brw3HomePhone]
      ,cld.[Brw3MonthlyIncome]
      ,cld.[Brw3MonthlyIncomeBase]
      ,cld.[Brw3MonthlyIncomeOther]
      ,cld.[Brw3AssetsMktVal]
      ,cld.[Brw3Employer]
      ,cld.[Brw3MonthsEmployed]
      ,cld.[Brw3SelfEmpFlg]
      ,cld.[Brw3MthsAtCurrAddr]
      ,cld.[Brw3FirstTimeHomebuyer]
      ,cld.[Brw3CitizenshipResidency]
      ,cld.[Brw4LName]
      ,cld.[Brw4FName]
      ,cld.[Brw4MI]
      ,cld.[Brw4Suffix]
      ,cld.[Brw4SSN]
      ,cld.[Brw4CreditScore]
      ,cld.[Brw4DOB]
      ,cld.[Brw4Age]
      ,cld.[Brw4Gender]
      ,cld.[Brw4Race1]
      ,cld.[Brw4Race2]
      ,cld.[Brw4Race3]
      ,cld.[Brw4Race4]
      ,cld.[Brw4Race5]
      ,cld.[Brw4Ethnicity]
      ,cld.[Brw4OptedOutHMDA]
      ,cld.[Brw4HomePhone]
      ,cld.[Brw4MonthlyIncome]
      ,cld.[Brw4MonthlyIncomeBase]
      ,cld.[Brw4MonthlyIncomeOther]
      ,cld.[Brw4AssetsMktVal]
      ,cld.[Brw4Employer]
      ,cld.[Brw4MonthsEmployed]
      ,cld.[Brw4SelfEmpFlg]
      ,cld.[Brw4MthsAtCurrAddr]
      ,cld.[Brw4FirstTimeHomebuyer]
      ,cld.[Brw4CitizenshipResidency]
      ,cld.[LnAppRecdDt]
      ,cld.[CancelWithdrawnDt]
      ,cld.[FileRecdDt]
      ,cld.[FileIncompleteDt]
      ,cld.[UndwrtRecDt]
      ,cld.[UndwrtCondApprlDt]
      ,cld.[UndwrtSuspendDt]
      ,cld.[UndwrtDeniedDt]
      ,cld.[UndwrtApprlDt]
      ,cld.[UndwrtModCondDt]
      ,cld.[UndwrtPend2ndReviewDt]
      ,cld.[ClsgPkgRecDt]
      ,cld.[PostClsgSuspendDt]
      ,cld.[PostClsgClearedDt]
      ,cld.[TargetShipDt]
      ,cld.[ShipToInvDt]
      ,cld.[DocPrepDt]
      ,cld.[DocSentDt]
      ,cld.[ClsgDt]
      ,cld.[NoteDt]
      ,cld.[NoteReceivedDt]
      ,cld.[NoteClearedDt]
      ,cld.[NoteShippedDt]
      ,cld.[FundedDt]
      ,cld.[WarehouseBank]
      ,cld.[AdvancedAmt]
      ,cld.[FundingMethod]
      ,cld.[InvShipMethod]
      ,cld.[InvTrackingNbr]
      ,cld.[Servicer]
      ,cld.[ServicerLnNbr]
      ,cld.[ShipToServicerDt]
      ,cld.[ServicingFee]
      ,cld.[InvestorName]
      ,cld.[InvestorRclDt]
      ,cld.[InvestorRclExpDt]
      ,cld.[InvestorRclType]
      ,cld.[InvestorLnNbr]
      ,cld.[InvestorCommitNbr]
      ,cld.[GrossSellPrice]
      ,cld.[ServiceRelPremium]
      ,cld.[NetSellPrice]
      ,cld.[AUSType]
      ,cld.[AUSRecommendation]
      ,cld.[AUSKey]
      ,cld.[LPDocClass]
      ,cld.[GLPurByInvDt]
      ,cld.[GLSaleGrossPrice]
      ,cld.[GLSaleSRP]
      ,cld.[GLSaleNetPrice]
      ,cld.[HOEPA]
      ,cld.[YearBuilt]
      ,cld.[NbrOfBedroomUnit1]
      ,cld.[NbrOfBedroomUnit2]
      ,cld.[NbrOfBedroomUnit3]
      ,cld.[NbrOfBedroomUnit4]
      ,cld.[EligibleRentUnit1]
      ,cld.[EligibleRentUnit2]
      ,cld.[EligibleRentUnit3]
      ,cld.[EligibleRentUnit4]
      ,cld.[MERS]
      ,cld.[MERSMinRegFlg]
      ,cld.[MERSMomFlg]
      ,cld.[InitialMIPremAmt]
      ,cld.[FinancedMIAmt]
      ,cld.[LenderMIPaidRtPct]
      ,cld.[APOR]
      ,cld.[APR]
      ,cld.[APRSprdPct]
      ,cld.[Appraiser]
      ,cld.[AppraiserLicenseNbr]
      ,cld.[SuperAppraiserLicenceNbr]
      ,cld.[AppraisalCompany]
      ,cld.[FieldworkObtained]
      ,cld.[LnOrigCompanyId]
      ,cld.[LnOriginatorId]
      ,cld.[TitleRights]
      ,cld.[VAFundingFee]
      ,cld.[FHAUpfrontMIP]
      ,cld.[FHAMIRenewalRate]
      ,cld.[BofAEligible]
      ,cld.[CitiEligible]
      ,cld.[GMACEligible]
      ,cld.[SunTrustEligible]
      ,cld.[USBankEligible]
      ,cld.[WellsEligible]
      ,cld.[ChaseEligible]
      ,cld.[ChaseUSDAEligible]
      ,cld.[FlagstarEligible]
      ,cld.[FannieEligible]
      ,cld.[FHLBEligible]
      ,cld.[GinnieEligible]
      ,cld.[FreddieEligible]
      ,cld.[EligibleInvestors]
      ,cld.[SMDSEligibleInvestors]
      ,cld.[RdyToAllocate]
      ,cld.[FC_ExpctdAllctnDt]
      ,cld.[RlcExpectClsgDt]
      ,cld.[BaseRate]
      ,cld.[RuralHsing]
      ,cld.[HelocPiggyBackFlg]
      ,cld.[NewMtgLiab2ndLien]
      ,cld.[NewHelocLiab2ndLien]
      ,cld.[NewHelocMaxLine2ndLien]
      ,cld.[ExistMtgLiab1stLien]
      ,cld.[ExistMtgLiab2ndLien]
      ,cld.[ExistMtgLiab3rdLien]
      ,cld.[ExistHelocLiab1stLien]
      ,cld.[ExistHelocMaxLine1stLien]
      ,cld.[ExistHelocLiab2ndLien]
      ,cld.[ExistHelocMaxLine2ndLien]
      ,cld.[ExistHelocLiab3rdLien]
      ,cld.[ExistHelocMaxLine3rdLien]
      ,cld.[Margin]
      ,cld.[CurrMargin]
      ,cld.[IntPaidThruDt]
      ,cld.[MailingStreetAddress]
      ,cld.[MailingCity]
      ,cld.[MailingState]
      ,cld.[MailingPostalCode]
      ,cld.[DifferentPropertyAddress]
      ,cld.[USAddress]
      ,cld.[FHACaseNbr]
      ,cld.[VACaseNbr]
      ,cld.[FNMProjectType]
      ,cld.[PUDFlag]
      ,cld.[DerivedPropTypeFHLMC]
      ,cld.[DerivedPropTypeRWT]
      ,cld.[FHLMCPropertyType]
      ,cld.[FHLMCCondoClass]
      ,cld.[FHLMCLoanPurpose]
      ,cld.[FHLMCMICompanyName]
      ,cld.[FHLMCBrw1Race1]
      ,cld.[FHLMCBrw1Race2]
      ,cld.[FHLMCBrw1Race3]
      ,cld.[FHLMCBrw1Race4]
      ,cld.[FHLMCBrw1Race5]
      ,cld.[FHLMCBrw1Ethnicity]
      ,cld.[FHLMCBrw1Gender]
      ,cld.[FHLMCBrw2Race1]
      ,cld.[FHLMCBrw2Race2]
      ,cld.[FHLMCBrw2Race3]
      ,cld.[FHLMCBrw2Race4]
      ,cld.[FHLMCBrw2Race5]
      ,cld.[FHLMCBrw2Ethnicity]
      ,cld.[FHLMCBrw2Gender]
      ,cld.[M60LateChargeFactor]
      ,cld.[M60LateChargeCode]
      ,cld.[M60LateChargeMinAmt]
      ,cld.[M60LateChargeMaxAmt]
      ,cld.[Z31RHSLoanNumber]
      ,cld.[E40TypeDisb]
      ,cld.[E40Sequence]
      ,cld.[E40BillCode]
      ,cld.[DMICategoryCode]
      ,cld.[DMIProductCode]
      ,cld.[DMILoanType]
      ,cld.[DMIOccupancyType]
      ,cld.[DMIConstructionType]
      ,cld.[DMIPropertyType]
      ,cld.[DMILoanPurpose]
      ,cld.[DMIOwnerType]
      ,cld.[DMIMtgeInsPmtFreq]
      ,cld.[DMIMtgeInsCompany]
      ,cld.[DMIARMPlanID]
      ,cld.[CitiMortgageType]
      ,cld.[CitiProductCode]
      ,cld.[CitiProgramType]
      ,cld.[CitiSubPrgmType]
      ,cld.[RWTLenderLnStatus]
      ,cld.[RWTLoanPurpose]
      ,cld.[RWTOccupancyType]
      ,cld.[RWTPropertyType]
      ,cld.[RWTProgramName]
      ,cld.[RWTAppraisalType]
      ,cld.[PortTrkgFlag]
      ,cld.[PaidOffFlag]
      ,cld.[SFC003]
      ,cld.[SFC007]
      ,cld.[SFC018]
      ,cld.[SFC019]
      ,cld.[SFC057]
      ,cld.[SFC062]
      ,cld.[SFC118]
      ,cld.[SFC127]
      ,cld.[SFC147]
      ,cld.[SFC150]
      ,cld.[SFC170]
      ,cld.[SFC180]
      ,cld.[SFC203]
      ,cld.[SFC211]
      ,cld.[SFC212]
      ,cld.[SFC221]
      ,cld.[SFC304]
      ,cld.[SFC361]
      ,cld.[SFC439]
      ,cld.[SFC460]
      ,cld.[SFC588]
      ,cld.[SFC807]
      ,cld.[SFC808]
      ,cld.[SFC904]
      ,cld.[SFC943]
      ,cld.[SFCD49]
      ,cld.[SFCH08]
      ,cld.[SFCH10]
      ,cld.[SFC1]
      ,cld.[SFC2]
      ,cld.[SFC3]
      ,cld.[SFC4]
      ,cld.[SFC5]
      ,cld.[SFC6]
      ,cld.[SFC7]
      ,cld.[SFC8]
      ,cld.[SFC9]
      ,cld.[SFC10]
      ,cld.[CntSFC]
      ,cld.[StringSFC]
      ,cld.[CondoProjStatusType]
      ,cld.[CondoProjAttachType]
      ,cld.[CondoProjDesignType]
      ,cld.[CondoProjUnitsSold]
      ,cld.[CondoProjTotalUnits]
      ,isNull(cld.[AttachmentType], '') AS [AttachmentType]
      ,cld.[ConstructionType]
      ,cld.[AVMModelName]
      ,cld.[PropertyValMethod]
      ,cld.[AffordableLoanFlag]
      ,cld.[RelocationLoanFlag]
      ,cld.[SharedEquityFlag]
      ,cld.[InvestorCollateralPrgm]
      ,cld.[GiftAmt]
      ,cld.[GiftFlg]
      ,cld.[NbrMonthsReserves]
      ,cld.[HomeownerPastThreeYearsFlg]
      ,cld.[NonOccupyingCoBorrowerFlg]
      ,cld.[NbrFinancedProperties]
      ,cld.[HPMLFlg]
      ,cld.[ReservesAmt],
              CASE WHEN cld.LnNbr <> 'NA' THEN SUBSTRING(cld.LnNbr, 1, 30)
                ELSE '' END AS [SellerLoanIdentifier],
              lld.GSEPropertyType as [LockLoanDataPropertyType],
              lf.GSEPropertyType as [LoanFeaturesPropertyType],
              td.BuydownRatePercent as [BuydownRatePercent],
              buydown._ChangeFrequencyMonths as [BuydownChangeFrequencyMonths],
              buydown._ContributorType as [BuydownContributorTypeOrig],
              buydown._DurationMonths as [BuydownDurationMonths],
              buydown._IncreaseRatePercent as [BuydownIncreaseRatePct],
              idu.AppraisalIdentifier as [AppraisalIdent],
              cld.MarginPct AS [MarginRatePercent],
              cld.InitialARMLockoutTerm AS [FirstPerChangeRateAdjustmentFrequencyMonthsCount],
              cld.SubseqARMLockoutTerm AS [SubsequentPerChangeRateAdjustmentFrequencyMonthsCount],
              arm._IndexCurrentValuePercent AS [DisclosedIndexRatePercent]
      FROM smds.SMDSCompassLoanDetails cld
      inner join LENDER_LOAN_SERVICE.dbo.vwLoan loan on loan.LoanNum = cld.LnNbr
      left outer join LENDER_LOAN_SERVICE.dbo.LOCK_LOAN_DATA lld on lld.loanGeneral_Id = loan.loanGeneral_id
      left outer join LENDER_LOAN_SERVICE.dbo.LOAN_FEATURES lf on lf.loanGeneral_Id = loan.loanGeneral_Id
      left outer join LENDER_LOAN_SERVICE.dbo.TRANSMITTAL_DATA td on td.loanGeneral_Id = loan.loanGeneral_Id
      left outer join LENDER_LOAN_SERVICE.dbo.BUYDOWN buydown on buydown.loanGeneral_Id = loan.loanGeneral_Id
      left outer join LENDER_LOAN_SERVICE.dbo.INVESTOR_DELIVERY_ULDD idu on idu.loanGeneral_Id = loan.loanGeneral_Id
      left outer join LENDER_LOAN_SERVICE.dbo.ARM arm on arm.loanGeneral_Id = loan.loanGeneral_Id
      WHERE (cld.InvestorName = 'Freddie Mac' AND SUBSTRING(cld.InvestorCommitNbr, 1, 2) = 'FD')
         OR (cld.InvestorName = 'Freddie Mac - MBS' AND SUBSTRING(cld.InvestorCommitNbr, 1, 2) = 'MC')
  eos

  CREATE_VIEW_FOR_DEV = <<-eos
    SELECT cld.*,
      CASE WHEN cld.LnNbr <> 'NA' THEN SUBSTRING(cld.LnNbr, 1, 30)
      ELSE '' END AS [SellerLoanIdentifier],
      lld.GSEPropertyType as [LockLoanDataPropertyType],
      lf.GSEPropertyType as [LoanFeaturesPropertyType],
      td.BuydownRatePercent as [BuydownRatePercent],
      buydown._ChangeFrequencyMonths as [BuydownChangeFrequencyMonths],
      buydown._ContributorType as [BuydownContributorTypeOrig],
      buydown._DurationMonths as [BuydownDurationMonths],
      buydown._IncreaseRatePercent as [BuydownIncreaseRatePct],
      idu.AppraisalIdentifier as [AppraisalIdent],
      cld.MarginPct AS [MarginRatePercent],
      cld.InitialARMLockoutTerm AS [FirstPerChangeRateAdjustmentFrequencyMonthsCount],
      cld.SubseqARMLockoutTerm AS [SubsequentPerChangeRateAdjustmentFrequencyMonthsCount],
      arm._IndexCurrentValuePercent AS [DisclosedIndexRatePercent]
    FROM smds.SMDSCompassLoanDetails cld
    inner join LENDER_LOAN_SERVICE.dbo.vwLoan loan on loan.LoanNum = cld.LnNbr
    left outer join LENDER_LOAN_SERVICE.dbo.LOCK_LOAN_DATA lld on lld.loanGeneral_Id = loan.loanGeneral_id
    left outer join LENDER_LOAN_SERVICE.dbo.LOAN_FEATURES lf on lf.loanGeneral_Id = loan.loanGeneral_Id
    left outer join LENDER_LOAN_SERVICE.dbo.TRANSMITTAL_DATA td on td.loanGeneral_Id = loan.loanGeneral_Id
    left outer join LENDER_LOAN_SERVICE.dbo.BUYDOWN buydown on buydown.loanGeneral_Id = loan.loanGeneral_Id
    left outer join LENDER_LOAN_SERVICE.dbo.INVESTOR_DELIVERY_ULDD idu on idu.loanGeneral_Id = loan.loanGeneral_Id
    left outer join LENDER_LOAN_SERVICE.dbo.ARM arm on arm.loanGeneral_Id = loan.loanGeneral_Id
    WHERE (cld.InvestorName = 'Freddie Mac' AND SUBSTRING(cld.InvestorCommitNbr, 1, 2) = 'FD')
    OR (cld.InvestorName = 'Freddie Mac - MBS' AND SUBSTRING(cld.InvestorCommitNbr, 1, 2) = 'MC')
  eos
  def self.sqlserver_create_view
    if Rails.env.development? || Rails.env.test?
      CREATE_VIEW_FOR_DEV
    else
      CREATE_VIEW_SQL
    end
  end

  belongs_to :master_loan, class_name: 'Master::Loan', foreign_key: 'LnNbr', primary_key: 'loan_num'
  has_many :hud_lines, through: :master_loan
  belongs_to :loan_general, foreign_key: 'LnNbr', primary_key: :loan_id
  has_many :liabilities, through: :master_loan
  has_many :master_borrowers, through: :master_loan, source: :borrowers
  has_one :transaction_detail, through: :loan_general
  has_many :custom_fields, through: :loan_general
  belongs_to :compass_loan_detail, :class_name => 'Smds::CompassLoanDetail', foreign_key: 'SellerLoanIdentifier', primary_key: :loan_number

  delegate :number_of_financed_properties, to: :loan_general, allow_nil: true
  delegate :has_pers_id?, :in_pers_list?, to: :custom_fields, allow_nil: true
  delegate :final_note_rate, :rate_adjustment_lifetime_cap_percent, :credit_report_identifier, :cpm_id, to: :master_loan, allow_nil: true
  delegate :trid_loan?, to: :master_loan, allow_nil: true
  delegate :AssumabilityIndicator, to: :compass_loan_detail, allow_nil: true

  def delivery_type
    "FHLMC"
  end

  def master_borrower(index)
    master_borrowers.by_position(index)
  end

  def subordinate_loans
    loans = liabilities.select(&:subordinate_loan?)
    loans << transaction_detail if transaction_detail && transaction_detail.subordinate?

    loans
  end

  def mortgage_insurance
    @mortgage_insurance ||= Smds::UlddMortgageInsurance.new(self)
  end

  def valuation
    @valuation ||= Fhlmc::ValuationType.new(self)
  end

  def pool
    Smds::Pool.find_by_pool_number(pool_id)
  end

  def pool_id
    self.InvestorCommitNbr
  end

  def loan_id
    self.SellerLoanIdentifier
  end

  def UPBAmount1
    self.UPB
  end

  def issue_date_upb
    self.CalcSoldScheduledBal
  end

  def first_payment_date
    self.ScheduledFirstPaymentDate
  end

  def last_paid_installment_date
    self.LastPaidInstallmentDueDate
  end

  def curtailment
    self.AggregateLoanCurtailmentAmount
  end

  def AddressLineText1
    extract self.PropertyStreetAddress, 100
  end

  def CityName1
    extract self.PropertyCity, 50
  end

  def PostalCode1
    extract self.PropertyPostalCode, 9
  end

  def StateCode1
    extract self.PropertyState, 2
  end

  def SpecialFloodHazardAreaIndicator
    true_or_false self.SpecialFloodHazardArea
  end

  def ProjectLegalStructureType
    return '' unless self.PropertyType.to_s.downcase.include?('condo')
    'Condominium'
  end

  def CondominiumProjectStatusType
    return '' unless condo?
    restrict_value_to self.CondoProjStatusType, 'Established', 'New'
  end

  def ProjectAttachmentType
    return '' unless self.ProjectLegalStructureType == 'Condominium' && self.ProjectClassificationIdentifier != 'ExemptFromReview'
    self.AttachmentType
  end

  def ProjectClassificationIdentifier
    from_proj_type = lambda do
      proj_type = self.ProjectType || ''
      next if self.AUSType != 'DU'
      next 'Project Eligibility Review services' if ( has_pers_id? && in_pers_list? == 'Yes')
      next 'CondominiumProjectManagerReview' if ( has_pers_id? && in_pers_list? == 'No')
      case proj_type
      when 'Reciprocal Review', 'TCondominium'
        'CondominiumProjectManagerReview'
      when 'PCondominium', 'QCondominium'
        'StreamlinedReview'
      when 'RCondominium', 'SCondominium'
        'FullReview'
      when 'UCondominium'
        'FHA_Approved'
      when 'VCondominium'
        'V Refi Plus'
      else
        nil
      end
    end

    from_fnm_proj = lambda do
      fnm_proj = self.FNMProjectType || ''
      next if self.AUSType != 'LP'
      case fnm_proj
        when 'PCondominium', 'QCondominium'
        'StreamlinedReview'
      when 'RCondominium', 'SCondominium', '2- to 4-unit Project', 'Detached Project', 'Established Project', 'New Project'
        'FullReview'
      when 'Reciprocal Review'
        next 'ProjectEligibilityReviewService' if (has_pers_id? && in_pers_list? == 'Yes')
        next 'CondominiumProjectManagerReview' if (has_pers_id? && in_pers_list? == 'No')
      when 'Streamlined Review'
        if self.ProductCode.in?(['C15FXD FR', 'C20FXD FR', 'C30FXD FR'])
          'ExemptFromReview'
        else
          'StreamlinedReview'
        end
      else
        nil
      end
    end

    from_proj_type.call || from_fnm_proj.call || ''
  end

  def condo?
    self.ProjectLegalStructureType == 'Condominium'
  end

  def ProjectDesignType
    return '' unless condo?
    return 'HighriseProject' if self.NbrOfStories > 7
    return 'MidriseProject' if self.NbrOfStories > 3
    return 'GardenProject'
  end

  def ProjectDwellingUnitCount
    return '' unless condo?
    format_num self.CondoProjTotalUnits
  end

  def ProjectDwellingUnitsSoldCount
    return '' unless condo?
    format_num self.CondoProjUnitsSold
  end

  def CondoProjectName
    return '' unless condo?
    extract self.ProjectName, 50
  end

  def PUDIndicator
    [self.PropertyType, self.FNMProjectType, self.RlcPropType].any? { |x| x.present? && x.upcase.include?('PUD') }
  end

  def FinancedUnitCount
    format_num self.NbrOfUnits
  end

  def PropertyEstateType
    restrict_value_to self.TitleRights, 'FeeSimple', 'Leasehold'
  end

  def PropertyFloodInsuranceIndicator
    true_or_false self.SpecialFloodHazardArea
  end

  def ConstructionMethodType
    type = self.ConstructionType
    return 'SiteBuilt' if type == 'NA'
    return 'SiteBuilt' unless type.present?
    restrict_value_to self.ConstructionType, 'Modular', 'Manufactured', 'SiteBuilt'
  end

  def PropertyStructureBuiltYear
    return '9999' if (self.YearBuilt.nil? || self.ProductCode.in?(['C15FXD FR', 'C20FXD FR', 'C30FXD FR']))
    extract self.YearBuilt, 4
  end

  def PropertyUsageType
    case self.PropertyOccupy
    when 'PrimaryResidence', 'SecondHome'
      self.PropertyOccupy
    when 'Investor'
      'Investment'
    else
      ''
    end
  end

  def BedroomCount1
    return '' unless should_list_bedroom_count?
    self.NbrOfBedroomUnit1.to_s
  end

  def BedroomCount2
    return '' unless should_list_bedroom_count?
    self.NbrOfBedroomUnit2.to_s
  end

  def BedroomCount3
    return '' unless should_list_bedroom_count?
    self.NbrOfBedroomUnit3.to_s
  end

  def BedroomCount4
    return '' unless should_list_bedroom_count?
    self.NbrOfBedroomUnit4.to_s
  end

  def PropertyDwellingUnitEligibleRentAmount1
    format_num self.EligibleRentUnit1
  end

  def PropertyDwellingUnitEligibleRentAmount2
    format_num self.EligibleRentUnit2
  end

  def PropertyDwellingUnitEligibleRentAmount3
    format_num self.EligibleRentUnit3
  end

  def PropertyDwellingUnitEligibleRentAmount4
    format_num self.EligibleRentUnit4
  end

  def AVMModelNameType
    valuation.avm_model
  end

  def PropertyValuationAmount
    format_num self.AppraisdValue
  end

  def PropertyValuationMethodType
    valuation.valuation_type
  end

  def PropertyValuationMethodTypeOtherDescription
    valuation.valuation_other_description
  end

  def PropertyValuationFormType
    valuation.valuation_form
  end

  def PropertyValuationEffectiveDate
    return if self.PropertyValuationMethodType.in?(%w(None Other))
    (format_date self.AppraisalDt)
  end

  def AppraisalIdentifier
    valuation_types = ['FullAppraisal', 'DriveBy', 'PriorAppraisalUsed']
    return '' unless valuation_types.include?(self.PropertyValMethod)
    ident = self.AppraisalIdent.presence || self.AppraisalDocID
    extract ident, 10
  end

  def CombinedLTVRatioPercent
    format_num self.CLTV, 4
  end

  def heloc?
    liabilities.any?(&:heloc?)
  end

  def HomeEquityCombinedLTVRatioPercent
    self.HCLTV if heloc?
  end

  def LoanAmortizationPeriodCount
    format_num self.LnAmortTerm
  end

  def LoanAmortizationType
    restrict_value_to self.LnAmortType, 'Fixed', 'AdjustableRate'
  end

  def amortization_type
    self.LoanAmortizationType
  end

  def LoanAmortizationPeriodType
    'Month'
  end

  def HMDA_HOEPALoanStatusIndicator
    true_or_false self.HOEPA
  end

  def InterestCalculationPeriodType
    'Month'
  end

  def ApplicationReceivedDate
    return '' if self.LnAppRecdDt == Date.new(1900, 1, 1) || self.LnAppRecdDt.blank?
    return self.LnAppRecdDt.strftime("%Y-%m-%d")
  end

  def BalloonIndicator
    true_or_false self.BalloonFlg
  end

  def BorrowerCount
    borrowers.size
  end

  def BuydownTemporarySubsidyIndicator
    true_or_false self.BuydownFlg
  end

  def CapitalizedLoanIndicator
    false
  end

  def ConstructionLoanIndicator
    ['ConstructionOnly', 'ConstructionToPermanent'].include?(self.LnPurpose)
  end

  def ConstructionLoanType
    return 'ConstructionToPermanent' if self.ConstructionLoanIndicator
    ''
  end

  def ConvertibleIndicator
    true_or_false self.ARMConvertibility
  end

  def EscrowIndicator
    self.EscrowWaiverFlg != 'Y' ? 'true' : 'false'
  end

  def InterestOnlyIndicator
    true_or_false self.InterestOnlyFlg
  end

  def LoanAffordableIndicator
    true_or_false self.AffordableLoanFlag
  end

  def PrepaymentPenaltyIndicator
    true_or_false self.PrepayPenaltyFlg
  end

  def RelocationLoanIndicator
    true_or_false self.RelocationLoanFlag
  end

  def SharedEquityIndicator
    true_or_false self.SharedEquityFlag
  end

  def LoanStateDate1
    format_date self.NoteDt
  end

  def BaseLTVRatioPercent
    format_num self.BaseLTV, 4
  end

  def LTVRatioPercent
    format_num self.LTV, 4
  end

  def LoanMaturityDate
    format_date self.MaturityDt
  end

  def LoanMaturityPeriodCount
    extract self.LnMaturityTerm, 3
  end

  def LoanMaturityPeriodType
    'Month'
  end

  def InitialPrincipalAndInterestPaymentAmount
    format_num self.PI, 2
  end

  def PaymentFrequencyType
    'Monthly'
  end

  def ScheduledFirstPaymentDate
    format_date self.FirstPmtDt
  end

  def TotalLiabilitiesMonthlyPaymentAmount
    format_num self.MonthlyDebtExp
  end

  def TotalMonthlyIncomeAmount
    format_num self.MonthlyIncome
  end

  def TotalMonthlyProposedHousingExpenseAmount
    format_num self.MonthlyHsingExp
  end

  def PriceLockDatetime
    format_date self.RlcDate
  end

  def LoanPurposeType
    restrict_value_to self.LnPurpose, 'Purchase', 'Refinance'
  end

  def MortgageType1
    case self.LoanType
    when 'Conventional', 'FHA', 'VA'
      self.LoanType
    when 'FarmersHomeAdministration'
      'USDARuralHousing'
    else
      ''
    end
  end

  def NoteAmount
    format_num self.LnAmt, 2
  end

  def NoteRatePercent
    format_num self.FinalNoteRate, 4
  end

  def InvestorOwnershipPercent
    '100'
  end

  def MortgageModificationIndicator
    false
  end

  def SellerLoanIdentifier
    extract self.LnNbr, 30
  end

  def LastPaidInstallmentDueDate
    format_date self.IntPaidThruDt
  end

  def DelinquentPaymentsOverPastTwelveMonthsCount
    '0'
  end

  def AppraiserLicenseIdentifier
    case self.PropertyValuationMethodType
    when 'DriveBy', 'FullAppraisal', 'PriorAppraisalUsed'
      extract self.AppraiserLicenseNbr if self.LoanType.eql?('Conventional')
    when 'Other'
      extract self.AppraiserLicenseNbr if self.PropertyValuationMethodTypeOtherDescription.eql?('FieldReview')
    else
      ''
    end
  end

  def AppraiserSupervisorLicenseIdentifier
    case self.PropertyValuationMethodType
    when 'DriveBy', 'FullAppraisal', 'PriorAppraisalUsed'
      extract self.SuperAppraiserLicenceNbr if self.LoanType.eql?('Conventional')
    when 'Other'
      extract self.SuperAppraiserLicenceNbr if self.PropertyValuationMethodTypeOtherDescription.eql?('FieldReview')
    else
      ''
    end
  end

  def LoanOriginatorIdentifier
    extract self.LnOriginatorId, 50
  end

  def LoanOriginatorType
    case self.LendingChannel
    when /^W0/
      'Broker'
    when /^A0/
      'Lender'
    when /^R0/
      'Correspondent'
    else
      ''
    end
  end

  def FirstMaximumRateChangePercent
    self.InitialCap
  end

  def SubsequentMaximumRateChangePercent
    self.IntervalCap
  end

  def FirstPerChangeRateAdjustmentFrequencyMonthsCount
    self.InitialARMLockoutTerm
  end

  def initial_fixed_period_effective_months_count
    self.FirstPerChangeRateAdjustmentFrequencyMonthsCount
  end

  def SubsequentPerChangeRateAdjustmentFrequencyMonthsCount
    self.SubseqARMLockoutTerm
  end

  def CeilingRatePercent
    rate_adjustment_lifetime_cap_percent.to_f + final_note_rate.to_f
  end

  def CurrentInterestRatePercent
    final_note_rate
  end

  def borrowers
    x = []
    1.upto(4) do |i|
      x << Smds::UlddBorrower.new(self, i) if master_borrower(i)
    end
    x
  end

  def LoanLevelCreditScore
    return '' if self.AUSType == 'LP'
    # borrowers.map { |b| b.credit_score.to_i }.reject(&:zero?).min.to_s
    self.RepresentativeFICO
  end

  def borrower_credit_score(curr_ix)
    case curr_ix
      when 0 then self.Brw1CreditScore
      when 1 then self.Brw2CreditScore
      when 2 then self.Brw3CreditScore
      when 3 then self.Brw4CreditScore
    end
  end

  def borrower_credit_score_source(curr_ix)

    source = case curr_ix
      when 0 then self.Brw1CreditScoreSource
      when 1 then self.Brw2CreditScoreSource
      else
        return nil
    end

    translate_source source
  end

  def LoanLevelCreditScoreSelectionMethodType
    return '' if self.LoanLevelCreditScore.blank?
    "MiddleOrLowerThenLowest"
  end

  def LoanOriginationCompanyIdentifier
    extract self.LnOrigCompanyId, 50
  end

  def PurchasePriceAmount
    return ''  unless self.LnPurpose == 'Purchase' && self.LienPriority == 'FirstLien'
    format_num self.SalePrice
  end

  def SectionOfActType
    return '502' if self.MortgageType1 == 'USDARuralHousing'
    return '' unless self.MortgageType1 == 'FHA'
    return '234c' if condo?
    '203b'
  end

  def LienPriorityType1
    restrict_value_to self.LienPriority, 'FirstLien', 'SecondLien'
  end

  def NoteDate
    format_date self.NoteDt
  end

  def LoanManualUnderwritingIndicator
    ['DU', 'LP'].include?(self.AUSType) ? false : true
  end

  def AutomatedUnderwritingSystemType
    case self.AUSType
    when 'DU'
      'DesktopUnderwriter'
    when 'LP'
      'LoanProspector'
    else
      ''
    end
  end

  def AutomatedUnderwritingCaseIdentifier
    return '' unless self.AutomatedUnderwritingSystemType == 'LoanProspector'
    extract self.AUSKey, 20
  end

  def AutomatedUnderwritingRecommendationDescription
    if self.AUSType == 'LP'
      return '' if self.AUSRecommendation == 'N/A'
      return 'Accept' if self.AUSRecommendation.include?('Accept')
      'Caution'
    elsif self.AUSType == 'DU'
      [nil, 'Out of Scope', 'Submit/Error'].include?(self.AUSRecommendation) ? '' : 'ApproveEligible'
    end
  end

  def InvestorFeatureIdentifiers
    input = self.StringSFC || ''
    input = '' if input == 'NA'
    features = input.scan /904|H10|H03|H04|903/
    features += valuation.additional_investor_features
    features.uniq
  end

  def MERS_MINIdentifier
    extract self.MERS, 30
  end

  def DelinquentPaymentsOverPastTwelveMonthsCount
    '0'
  end

  def RefinanceCashOutAmount
    return '' unless self.LnPurpose == 'Refinance'
    format_num self.CashOutAmt, 2
  end

  def RefinanceCashOutDeterminationType
    mapping = {
      'CashOutLimited' => 'NoCashOut',
      'CashOutOther' => 'CashOut',
      'CashOutDebtConsolidation' => 'CashOut',
      'CashOutHomeImprovement' => 'CashOut',
      'ChangeInRateTerm' => 'NoCashOut',
      'NoCashOutFHAStreamlinedRefinance' => 'NoCashOut',
      'VAStreamlinedRefinance' => 'NoCashOut'
    }
    mapping[self.RefPurposeType] || ''
  end

  def RefinanceProgramIdentifier
    return 'ReliefRefinanceOpenAccess' if (self.ProductCode || '').ends_with?('FR')
    ''
  end

  def AggregateLoanCurtailmentAmount
    format_num self.CalcAggregateLoanCurtailments, 2
  end

  def FullName
    return 'Cole Taylor Bank' unless self.LendingChannel.starts_with?('R0')
    self.InstitutionName
  end

  def escrow_items
    items = []
    hud_lines.each do |line|
      if line.system_fee_name != "Mortgage Insurance"
        next if line.fee_category != "InitialEscrowPaymentAtClosing" || !line.net_fee_indicator?
      end
      next unless line.hud_type == 'HUD'

      fee_name_mapping = {
        "Annual Assessments"    => "OtherTax",
        "City Taxes"            => "CityPropertyTax",
        "County Taxes"          => "CountyPropertyTax",
        "Earthquake Insurance"  => "EarthquakeInsurance",
        "Flood Insurance"       => "FloodInsurance",
        "Homeowners Insurance"  => "HazardInsurance",
        "Hurricane Insurance"   => "StormInsurance",
        "Mortgage Insurance"    => "MortgageInsurance",
        "Other Insurance"       => "Other" ,
        "Property Taxes"        => "StatePropertyTax",
        "School Taxes"          => "SchoolPropertyTax", 
        "Village Taxes"         => "TownshipPropertyTax",
        "Wind Insurance"        => "StormInsurance"
      }

      type = fee_name_mapping[line.system_fee_name]
      next if type.nil?
      next if line.monthly_amount.nil? || line.monthly_amount == 0
      items << { type: type, amount: format_num(line.monthly_amount, 2), months: line.num_months}
    end
    items
  end

  def LoanAcquisitionScheduledUPBAmount
    value = self.CalcSoldScheduledBal.presence || 0
    "%.2f" % value
  end

  def BuydownInitialDiscountPercent
    format_num self.BuydownRatePercent, 4
  end

  def BuydownChangeFrequencyMonthsCount
    format_num self.BuydownChangeFrequencyMonths
  end

  def BuydownIncreaseRatePercent
    format_num self.BuydownIncreaseRatePct, 4
  end

  def BuydownDurationMonthsCount
    format_num self.BuydownDurationMonths
  end

  def BuydownContributorType
    restrict_value_to self.BuydownContributorTypeOrig, 'Borrower', 'Lender', 'Other'
  end

  def BankruptcyIndicator
    (self.Bankruptcy == 'N') ? 'false' : 'true'
  end

  def LoanForeclosureOrJudgmentIndicator
    (self.Foreclosure == 'N') ? 'false' : 'true'
  end

  def EmploymentBorrowerSelfEmployedIndicator
    (self.SelfEmpFlg == 'N') ? 'false' : 'true'
  end

  def RelatedInvestorLoanIdentifier
    ''
  end

  def RelatedLoanInvestorType
    return '' unless self.ProductCode.present? && self.ProductCode.include?('FR')
    'FRE'
  end

  def InvestorCollateralProgramIdentifier
    if self.PropertyValuationMethodType == 'None' && ['LP', 'DU'].include?(self.AUSType)
      'PropertyInspectionWaiver'
    else
      ''
    end
  end

  def OtherFundsCollectedAtClosingAmount
    return '' if self.EscrowIndicator == 'false'
    total_amount = self.EscrowAcctBal.to_f - self.HUD1010AggregateAdj.to_f
    format_num(total_amount,2)
  end

  def OtherFundsCollectedAtClosingType
    return '' if self.OtherFundsCollectedAtClosingAmount == ''
    'EscrowFunds'
  end

  def FirstRateChangePaymentEffectiveDate
    first_rate_change_date + 1.month
  end

  def FirstPerChangeRateAdjustmentEffectiveDate
    first_rate_change_date
  end

  def first_rate_change_date
    date = self.FirstRateChgDt
    return date.to_date if date.respond_to?(:to_date)
    Date.parse(date).to_date
  end

  def SubsequentPerChangeRateAdjustmentEffectiveDate
    first_rate_change_date + 1.year
  end
  alias_method :NextRateAdjustmentEffectiveDate, :first_rate_change_date

  def arm?
    self.LoanAmortizationType == 'AdjustableRate'
  end

  def TotalMortgagedPropertiesCount
    number_of_financed_properties
  end

  def BorrowerReservesMonthlyPaymentCount
    self.NbrMonthsReserves.to_i
  end

  def index_source_type
    'LIBOROneYearWSJDaily'
  end

  def index_source_type_other_description
    #not applicable
  end

  def document_custodian
    #not sure how to fill this in, if it is even needed for FHLMC
  end

  def servicer_number
    '272190003'
  end

  private

  def translate_source(source)
    case source
    when /experian/i
      'Experian'
    when /equifax/i
      'Equifax'
    when /transunion/i
      'TransUnion'
    else
      ''
    end
  end

  RACES = [ 'AmericanIndianOrAlaskaNative', 'Asian',
          'BlackOrAfricanAmerican', 'NativeHawaiianOrOtherPacificIslander', 'White',
          'InformationNotProvidedByApplicantInMailInternetOrTelephoneApplication',
          'NotApplicable' ]

  def has_separate_billing_address?
    true_or_false self.DifferentPropertyAddress
  end

  def should_list_bedroom_count?
    self.PropertyUsageType == 'Investment' || self.NbrOfUnits > 1
  end

  include Smds::DataCleanupMethods
  include Smds::UlddMethods

end

unless defined?(FhlmcLoan)
  FhlmcLoan = Smds::FhlmcLoan #Rails can't make up it's mind about which one it is looking for.
end


