module Smds
  module DeliveryModelMethods
    #methods shared between the FnmaLoan and FhlbLoan models.  

    def pool
      Smds::Pool.find_by_pool_number(pool_id)
    end

    delegate :investor_product_plan_identifier, to: :pool, allow_nil: true
    delegate :final_note_rate, :rate_adjustment_lifetime_cap_percent, :credit_report_identifier, :cpm_id, to: :master_loan, allow_nil: true

    def ProjectAttachmentType
      return '' unless self.ProjectLegalStructureType == 'Condominium' && self.cpm_id.blank?
      self.AttachmentType
    end

    def master_borrower(index)
      master_borrowers.by_position(index)
    end

    def borrowers
      x = []
      1.upto(4) do |i|
        x << Smds::UlddBorrower.new(self, i) if master_borrower(i)
      end
      x[0..1] #FNMA will only accept, at most, two borrowers
    end

    def subordinate_loans
      loans = liabilities.select(&:subordinate_loan?)
      loans << transaction_detail if transaction_detail && transaction_detail.subordinate?

      loans
    end

    def pool_id
      commitment_id = self.InvestorCommitmentIdentifier
      if commitment_id.present?
        "FN#{commitment_id}"
      else
        "ME#{self.InvestorContractIdentifier}"
      end
    end

    def loan_id
      self.SellerLoanIdentifier
    end

    def issue_date_upb
      self.LoanAcquisitionScheduledUPBAmount
    end

    def current_upb
      self.UPBAmount1
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

    def initial_fixed_period_effective_months_count
      self.FirstPerChangeRateAdjustmentFrequencyMonthsCount
    end

    def CeilingRatePercent
      rate_adjustment_lifetime_cap_percent.to_f + final_note_rate.to_f
    end

    def CurrentInterestRatePercent
      final_note_rate
    end

    def FirstRateChangePaymentEffectiveDate
      d = self.FirstRateChgDt
      return unless d
      d.to_date + 1.month
    end

    def FirstPerChangeRateAdjustmentEffectiveDate
      d = self.FirstRateChgDt
      d && d.to_date
    end

    def SubsequentPerChangeRateAdjustmentEffectiveDate
      d = self.FirstRateChgDt
      return unless d
      d.to_date + 1.year
    end
    alias_method :NextRateAdjustmentEffectiveDate, :FirstPerChangeRateAdjustmentEffectiveDate

    def arm?
      self.LoanAmortizationType == 'AdjustableRate'
    end

    def amortization_type
      self.LoanAmortizationType
    end

    def short_investor_contract_identifier
      self.InvestorContractIdentifier.to_s[0..5] #FNMA will only accept 6 digit characters
    end

    def guarantee_fee_percent
      case self.FirstPerChangeRateAdjustmentFrequencyMonthsCount.to_i
      when 84
        47
      when 60
        49
      end
    end

    def TotalMortgagedPropertiesCount
      number_of_financed_properties
    end

    def index_source_type
      'Other'
    end

    def index_source_type_other_description
      '1YearWallStreetJournalLIBORRateDaily'
    end

    def primary_borrower_credit_repository_source_indicator
      primary_borrower_credit_repository_source_type.present?
    end

    def primary_borrower_credit_repository_source_type
      source = master_borrower(1).try(:middle_credit_score_source) || self.PB_CreditRepositorySourceType

      translate_source source
    end

    def primary_borrower_credit_score_value
      master_borrower(1).try(:middle_credit_score) || self.PB_CreditScoreValue
    end

    def coborrower_credit_repository_source_indicator
      coborower_credit_repository_source_type.present?#self.CB_CreditRepositorySourceIndicator
    end

    def coborower_credit_repository_source_type
      source = master_borrower(2).try(:middle_credit_score_source) || self.CB_CreditRepositorySourceType

      translate_source(source)
    end

    def coborrower_credit_score_value
      master_borrower(2).try(:middle_credit_score) || self.CB_CreditScoreValue
    end

    def LoanLevelCreditScore
      self.RepresentativeFICO
      # borrowers.map { |b| b.credit_score.to_i }.reject(&:zero?).min.to_s
    end

    def LoanLevelCreditScoreSelectionMethodType
      return unless self.LoanLevelCreditScore
      "MiddleOrLowerThenLowest"
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

    ## Refactoring of FNMA SQL begin

    def ProjectDesignType
      return '' unless (condo? && project_type_match? && condo_attached?)
      return '' if self.CondoProjDesignType == "NA"
      self.CondoProjDesignType
    end

    def ProjectDwellingUnitCount
      return '' unless ( condo? && project_type_match? && condo_attached? )
      return '' if self.CondoProjTotalUnits == 'NA'
      self.CondoProjTotalUnits
    end

    def ProjectDwellingUnitsSoldCount
      return '' unless ( condo? && project_type_match? && condo_attached? )
      return '' if self.CondoProjUnitsSold == 'NA'
      self.CondoProjUnitsSold
    end

    def CondominiumProjectStatusType
      return '' unless condo?
      restrict_value_to self.CondoProjStatusType, 'Established', 'New'
    end

    def BedroomCount index
      count = self["NbrOfBedroomUnit#{index}"]
      return '' if count.nil?
      (isInvestor || notInvestor) ? count : ''
    end

    def PropertyDwellingUnitEligibleRentAmount index
      rentUnit = self["EligibleRentUnit#{index}"]
      return rentUnit.floor if (isInvestor || notInvestor) && (rentUnit.to_f > 0)
      ''
    end

    def PropertyFloodInsuranceIndicator
      self.SpecialFloodHazardArea == "Y"
    end

    def ConvertibleIndicator
      self.ARMConvertibility == "Y"
    end

    def EscrowIndicator
      self.EscrowWaiverFlg != "Y"
    end

    def InterestOnlyIndicator
      self.InterestOnlyFlg == "Y"
    end

    def LoanAffordableIndicator
      self.AffordableLoanFlag == "Y"
    end

    def PrepaymentPenaltyIndicator
      self.PrepayPenaltyFlg == "Y"
    end

    def RelocationLoanIndicator
      self.RelocationLoanFlag == "Y"
    end

    def SharedEquityIndicator
      self.SharedEquityFlag == "Y"
    end

    def AutomatedUnderwritingSystemType
      return 'DesktopUnderwriter' if isDu
      return 'Other' if isLp
      ''
    end

    def AutomatedUnderwritingSystemTypeOtherDescription
      return 'LoanProspector' if isLp
      ''
    end

    def LoanManualUnderwritingIndicator
      return false if isDu || isLp
      true
    end

    def AutomatedUnderwritingCaseIdentifier
      return self.AUSKey if isDu && self.AUSKey != 'NA'
      ''
    end

    def InvestorFeatureIdentifier index
      base_index = index - 1
      return identifier6 if index == 6
      return '' unless self.CntSFC.to_i > base_index
      from = base_index * 3 # 3 characters required to for each investor feature
      to = from + 2
      self.StringSFC[from..to]
    end

    def mortgage_insurance
      @mortgage_insurance ||= Smds::UlddMortgageInsurance.new(self)
    end

    def AutomatedUnderwritingRecommendationDescription
      if isDu && self.AUSRecommendation != 'NA'
        case self.AUSRecommendation
        when 'Approve/Eligible'
          'ApproveEligible'
        when 'Approve/Ineligible'
          'ApproveIneligible'
        when 'EA-I/Eligible'
          'EAIEligible'
        when 'EA-II/Eligible'
          'EAIIEligible'
        when 'EA-III/Eligible'
          'EAIIIEligible'
        when 'EA-I/Ineligible'
          'EAIIneligible'
        when 'EA-II/Ineligible'
          'EAIIIneligible'
        when 'EA-III/Ineligible'
          'EAIIIIneligible'
        when 'Refer/Eligible'
          'ReferEligible'
        when 'Refer/Ineligible'
          'ReferIneligible'
        when 'Refer W Caution/IV'
          'ReferWithCautionIV'
        when 'Submit/Error'
          'Error'
        when 'Out of Scope'
          'OutofScope'
        else
          'Unknown'
        end
      else
        ''
      end
    end

    def LoanPurposeType
      restrict_value_to self.LnPurpose, 'Purchase', 'Refinance'
    end

    def LienPriorityType1
      restrict_value_to self.LienPriority, 'FirstLien', 'SecondLien'
    end

    def PropertyEstateType
      restrict_value_to self.TitleRights, 'FeeSimple', 'Leasehold'
    end

    def PUDIndicator
      self.PropertyType.upcase.include?('PUD')
    end

    def ConstructionMethodType
      restrict_value_to self.ConstructionType, 'Modular', 'Manufactured', 'SiteBuilt'
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

    def FinancedUnitCount
      format_num self.NbrOfUnits
    end

    def PropertyStructureBuiltYear
      extract self.YearBuilt, 4
    end

    def SpecialFloodHazardAreaIndicator
      self.SpecialFloodHazardArea == "Y"
    end

    def LoanAmortizationType
      restrict_value_to self.LnAmortType, 'Fixed', 'AdjustableRate'
    end

    def BalloonIndicator
      self.BalloonFlg == "Y"
    end

    def BuydownTemporarySubsidyIndicator
      self.BuydownFlg == "Y"
    end

    def BorrowerCount
      return format_num(self.NbrOfBrw) if self.NbrOfBrw > 0
      ''
    end

      ## functions used within

    def identifier6
      indicator = "150" if self.NbrFinancedProperties.to_i > 4
      indicator = self.StringSFC[15..17] if self.CntSFC.to_i > 5
      return (indicator || '')
    end

    def isLp
      self.AUSType == "LP"
    end

    def isDu
      self.AUSType == "DU"
    end

    def isInvestor
      self.PropertyOccupy == 'Investor' && self.NbrOfUnits > 0
    end

    def notInvestor
      self.PropertyOccupy != 'Investor' && self.NbrOfUnits > 1
    end

    def condo?
      self.ProjectLegalStructureType == 'Condominium'
    end

    def ProjectLegalStructureType
      return '' unless self.PropertyType.to_s.downcase.include?('condo')
      'Condominium'
    end

    def project_type_match?
      valid_types = ['P','Q','R','S','T','U','V']
      self.ProjectType.first.in?(valid_types)
    end

    def condo_attached?
      self.CondoProjAttachType == "Attached"
    end

    def InvestorCollateralProgramIdentifier
      return '' if self.PropertyValMethod != 'None'
      self.InvestorCollateralPrgm
    end

    def BorrowerReservesMonthlyPaymentCount
      count = self.NbrMonthsReserves.to_i
      (count > 999) ? 999 : count
    end

    ## Refactoring of FNMA SQL end

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

  end
end
