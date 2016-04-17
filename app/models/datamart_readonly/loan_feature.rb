class LoanFeature < DatabaseDatamartReadonly
  belongs_to :closing_request_received, :foreign_key => 'loan_general_id', :primary_key => 'id'
  belongs_to :loan_general
  
  scope :not_archived_from_lender_view, where(archived_from_lender_view_indicator: false)

  CREATE_VIEW_SQL = <<-eos
      SELECT     LOAN_FEATURES_id AS id,
             loanGeneral_Id AS loan_general_id,
             AssumabilityIndicator AS assumability_indicator,
             BalloonIndicator AS balloon_indicator,
             BalloonLoanMaturityTermMonths AS balloon_loan_maturity_term_months,
             CounselingConfirmationIndicator AS counseling_confirmation_indicator,
             DownPaymentOptionType AS down_payment_option_type,
             EscrowWaiverIndicator AS escrow_waiver_indicator,
             FREOfferingIdentifier AS fre_offering_identifier,
             FNMProductPlanIndentifier AS fnm_product_plan_identifier,
             GSEProjectClassificationType AS gse_project_classification_type,
             GSEPropertyType AS gse_property_type,
             HELOCMaximumBalanceAmount AS heloc_maximum_balance_amount,
             LienPriorityType AS lien_priority_type,
             LoanDocumentationType AS loan_documentation_type,
             LoanRepaymentType AS loan_repayment_type,
             LoanScheduledClosingDate AS loan_scheduled_closing_date,
             MICoveragePercent AS mi_coverage_percent,
             NegativeAmortizationLimitPercent AS negative_amortization_limit_percent,
             PaymentFrequencyType AS payment_frequency_type,
             PrepaymentPenaltyIndicator AS prepayment_penalty_indicator,
             FullPrepaymentPenaltyOptionType AS full_prepayment_penalty_option_type,
             PrepaymentRestrictionIndicator AS prepayment_restriction_indicator,
             ProductDescription AS product_description,
             ProductName AS product_name,
             ScheduledFirstPaymentDate AS scheduled_first_payment_date,
             NoAppraisalMortgageIndicator AS no_appraisal_mortgage_indicator,
             SecondaryFinancingType AS secondary_financing_type,
             EstimatedClosingDate AS estimated_closing_date,
             APRSpreadPercent AS apr_spread_percent,
             CoveredUnderHOEPA AS covered_under_hoepa,
             InterestOnlyTerm AS interest_only_term,
             LoanDocumentationTypeOtherDescription AS loan_documentation_type_other_description,
             NameDocumentsDrawnInType AS name_documents_drawn_in_type,
             LoanFinalWithLenderDate AS loan_final_with_lender_date,
             ArchivedFromOriginatorViewIndicator AS archived_from_originator_view_indicator,
               ArchivedFromLenderViewIndicator AS archived_from_lender_view_indicator,
               FNMProjectClassificationType AS fnm_project_classification_type,
             FNMProjectClassificationTypeOtherDescription	AS fnm_project_classification_type_other_description,
             RESPAConformingYearType AS respa_conforming_year_type,
             RequestedSettlementDate AS requested_settlement_date,
             RequestedClosingDate AS requested_closing_date,
             CCommitmentDate AS c_commitment_date
      FROM       LENDER_LOAN_SERVICE.dbo.[LOAN_FEATURES]
    eos
  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
