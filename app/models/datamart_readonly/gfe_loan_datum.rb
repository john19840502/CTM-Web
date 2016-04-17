class GfeLoanDatum < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT  [GFE_LOAN_DATA_id]              AS id,
              [loanGeneral_Id]                AS loan_general_id,
              [RequestedInterestRatePercent]  AS gfe_requested_interest_rate_percent,
              [OriginalLoanAmount]            AS original_loan_amount,
              [LoanAmortizationTermMonths]    AS loan_amortization_term_months,
              [PropertyStreetAddress]         AS property_street_address,
              [PropertyStreetAddressNumber]   AS property_street_address_number,
              [PropertyStreetAddressName]     AS property_street_address_name,
              [PropertyCity]                  AS property_city,
              [PropertyState]                 AS property_state,
              [PropertyPostalCode]            AS property_postal_code,
              LoanProgram                     AS loan_program

      FROM       LENDER_LOAN_SERVICE.dbo.[GFE_LOAN_DATA]
    eos



  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end

  # [BorrowerFirstName] [varchar](50) NULL,
  # [BorrowerMiddleName] [varchar](50) NULL,
  # [BorrowerLastName] [varchar](50) NULL,
  # [LoanProgram] [varchar](100) NULL,
  # [PropertyStreetAddressUnit] [varchar](10) NULL,
