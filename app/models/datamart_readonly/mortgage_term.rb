class MortgageTerm < DatabaseDatamartReadonly
  belongs_to :loan_general
  has_one :cond_pending_review, through: :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT
        MORTGAGE_TERMS_id                AS id,
        loanGeneral_Id                   AS loan_general_id,
        AgencyCaseIdentifier             AS agency_case_identifier,
        ARMTypeDescription               AS arm_type_description,
        BaseLoanAmount                   AS base_loan_amount,
        BorrowerRequestedLoanAmount      AS borrower_requested_loan_amount,
        LenderCaseIdentifier             AS lender_case_identifier,
        LoanAmortizationTermMonths       AS loan_amortization_term_months,
        LoanAmortizationType             AS loan_amortization_type,
        MortgageType                     AS mortgage_type,
        OtherAmortizationTypeDescription AS other_amortization_type_description,
        OtherMortgageTypeDescription     AS other_mortgage_type_description,
        RequestedInterestRatePercent     AS requested_interest_rate_percent,
        IncludeOtherIncomeAssets         AS include_other_income_assets,
        NotIncludeSpouseIncomeAssets     AS not_include_spouse_income_assets

      FROM       LENDER_LOAN_SERVICE.dbo.[MORTGAGE_TERMS]
    eos
  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
