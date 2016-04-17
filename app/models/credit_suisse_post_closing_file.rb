class CreditSuissePostClosingFile < DatabaseDatamartReadonly

  def self.primary_key
    'seller_loan_number'
  end

  belongs_to :smds_jumbo_fixed_loan, :class_name => 'Smds::JumboFixedLoan', primary_key: 'loan_number', foreign_key: 'seller_loan_number'

  CREATE_VIEW_SQL = <<-eos
    SELECT 
       CLD.LnNbr              AS seller_loan_number,
       CLD.Brw1LName          AS borrower1_last_name,
       CLD.LnAmt              AS original_loan_amount,
       CLD.UPB                AS actual_unpaid_principal_balance,
       NULL                   AS scheduled_next_payment_due_date,
       CONVERT(varchar, CLD.NextPmtDt, 101)
                              AS actual_next_payment_due_date,
       NULL                   AS scheduled_interest_paid_through_date,
       CONVERT(varchar, CLD.IntPaidThruDt, 101)
                              AS actual_interest_paid_through_date,
       CLD.LnAmortTerm        AS original_loan_term,
       CLD.LTV                AS ltv,
       CLD.CLTV               AS cltv,
       CLD.SubordinateFinance AS junior_balance,
       CLD.MICompanyName      AS mortgage_insurance_company,
       CLD.MICertNbr          AS mortgage_insurance_certificate_number,
       CLD.MiCoveragePct      AS mortgage_insurance_coverage_percent,
       CLD.RepresentativeFICO AS credit_score,
       CLD.Brw1CreditScore    AS borrower1_fico_score,
       CLD.Brw2CreditScore    AS borrower2_fico_score,
       CONVERT(varchar, CLD.NoteDt, 101)
                              AS note_date,
       CONVERT(varchar, CLD.FirstPmtDt, 101)
                              AS first_payment_date,
       CONVERT(varchar, CLD.MaturityDt, 101)
                              AS maturity_date,
       DATEDIFF(month, CLD.IntPaidThruDt, CLD.MaturityDt)
                              AS remaining_term,
       CLD.BaseRate           AS gross_rate,
       CLD.ServicingFee       AS servicing_fee,
       NULL                   AS lender_paid_mortgage_insurance_amount,
       CLD.FinalNoteRate      AS net_rate,
       NULL                   AS arm_gross_margin,    -- ARM: Gross Margin
       NULL                   AS arm_net_margin,      -- ARM: Net Margin
       NULL                   AS arm_next_pay_change, -- ARM: Next Pay Adjustment Date
       NULL                   AS arm_first_adj_cap,   -- ARM: Periodic Rate Cap During Initial Hybrid Term (Eg 3/1/5 Caps = 3)
       NULL                   AS arm_periodic_cap,    -- ARM: Periodic Rate Cap After Initial Hybrid Term (Eg 3/1/5 Caps = 1)
       NULL                   AS arm_life_cap,        -- ARM: Lifetime Rate Cap After Initial Hybrid Term (Eg 3/1/5 Caps = 5)
       NULL                   AS arm_max_rate,        -- ARM: Lifetime Maximum Rate (Orig_Rate + Lifecap)
       NULL                   AS arm_min_rate,        -- ARM: Lifetime Minimum Rate
       CLD.[PI]               AS original_principal_and_interest_payment,
       CLD.[PI]               AS current_principal_and_interest_payment,
       CLD.EscrowAcctPmtsIn   AS escrow_payment,
       NULL                   AS payment_history,
       CLD.AppraisdValue      AS property_appraised_value,
       CLD.SalePrice          AS property_sales_price,
       CLD.ProductCode        AS product_type,
       CASE UPPER(RTRIM(CLD.LnPurpose))
         WHEN 'PURCHASE' THEN 'Purchase'
         WHEN 'REFINANCE' THEN CASE UPPER(RTRIM(CLD.RefPurposeType))
                                 WHEN 'CASHOUTDEBTCONSOLIDATION' THEN 'Cash Out'
                                 WHEN 'CASHOUTHOMEIMPROVEMENT'   THEN 'Cash Out'
                                 WHEN 'CASHOUTOTHER'             THEN 'Cash Out'
                                 ELSE 'Refinance'
                               END
         ELSE NULL
       END                    AS purpose_code,
       CLD.PropertyOccupy     AS occupancy_type,
       CLD.PropertyType       AS property_type,
       CLD.NbrOfUnits         AS number_of_units,
       CLD.Brw1FName          AS borrower1_first_name,
       CLD.Brw1Employer       AS borrower1_employer,
       CLD.SelfEmpFlg         AS self_employed,
       CLD.FirstTimeHomebuyer AS first_time_home_buyer,
       CLD.PropertyStreetAddress
                              AS property_address,
       CLD.PropertyCity       AS property_city,
       CLD.PropertyCounty     AS property_county,
       CLD.PropertyState      AS property_state,
       CLD.PropertyPostalCode AS property_zip,
       CLD.Brw1SSN            AS borrower1_ssn,
       CLD.Brw2SSN            AS borrower2_ssn,
       CLD.Brw1Ethnicity      AS borrower1_ethnicity,
       CLD.Brw1Race1          AS borrower1_race,
       CLD.Brw1Gender         AS borrower1_gender,
       CLD.Brw2Ethnicity      AS borrower2_ethnicity,
       CLD.Brw2Race1          AS borrower2_race,
       CLD.Brw2Gender         AS borrower2_gender,
       CLD.Brw2FName          AS borrower2_first_name,
       CLD.Brw2LName          AS borrower2_last_name,
       CLD.Brw1MonthlyIncome  AS borrower1_income,
       CLD.Brw2MonthlyIncome  AS borrower2_income,
       CLD.HsingExpRatio      AS front_ratio,
       CLD.DTI                AS back_ratio,
       CLD.ReservesAmt        AS reserve_assets,
       CLD.MonthlyDebtExp     AS monthly_debt_expense,
       CLD.MonthlyHsingExp    AS monthly_housing_expense,
       CASE UPPER(RTRIM(CLD.LnDocType))
         WHEN 'FULLDOCUMENTATION' THEN 'FULL'
         ELSE NULL
       END                    AS document_type,
       NULL AS arm_index, -- ARM: Index On Which The Mortgage Loan Will Float
       CLD.InterestOnlyFlg    AS interest_only_flag,
       CLD.InterestOnlyTerm   AS interest_only_period,
       'N'                    AS pledged_asset,
       NULL                   AS pledged_asset_amount,
       CLD.YearBuilt          AS property_year_built,
       CLD.Brw1Age            AS borrower1_age,
       CONVERT(varchar, CLD.Brw1DOB, 101)
                              AS borrower1_date_of_birth,
       CLD.Brw2Age            AS borrower2_age,
       CONVERT(varchar, CLD.Brw2DOB, 101)
                              AS borrower2_date_of_birth,
       CLD.PrepayPenaltyFlg   AS prepayment_penalty,
       CLD.Assumable          AS assumable,
       NULL                   AS arm_lookback, -- ARM: Lookback
       NULL                   AS arm_rounding_factor, -- ARM: Type Of Rate Rounding (Eg 0.125)
       NULL                   AS servicer_method, -- ??? Actual Or Scheduled
       'Released'             AS servicing_rights,
       CLD.Servicer           AS servicer,
       CASE LEFT(CLD.LnNbr, 1)
         WHEN '1' THEN 'Retail'
         WHEN '4' THEN 'Consumer Direct' -- Retail
         WHEN '6' THEN 'Wholesale' -- Broker
         WHEN '8' THEN 'Mini-Correspondent' -- Broker
         ELSE NULL
       END                    AS origination_channel,
       CLD.MERS               AS mers_number,
       CONVERT(varchar, CLD.RlcDate, 101)
                              AS lock_date,
       CONVERT(varchar, CLD.RlcDate, 101)
                              AS pricing_date,
       CLD.RlcPeriod          AS lock_term,
       NULL                   AS extension_days,
       CLD.GrossBuyPrice      AS base_price,
       (ISNULL(CLD.NetBuyPrice, 0) + ISNULL(CLD.OriginatorCompensation, 0)) - ISNULL(CLD.GrossBuyPrice, 0)
                              AS price_adjustments,
       ISNULL(CLD.NetBuyPrice, 0) + ISNULL(CLD.OriginatorCompensation, 0)
                              AS net_price,
       CLD.CashOutAmt         AS cashout_amount,
       CONVERT(decimal(5,2), CONVERT(decimal, CLD.Brw1MthsAtCurrAddr) / 12)
                              AS years_in_home,
       CLD.NbrFinancedProperties                   
                              AS number_of_mortgaged_properties,
       CONVERT(decimal(5,2), CONVERT(decimal, CLD.Brw1MonthsEmployed) / 12)
                              AS length_of_employment,
       'FULL'                 AS type_of_income_verification,
       'FULL'                 AS type_of_asset_verification
    FROM CTM.smds.SMDSCompassLoanDetails CLD
  eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def self.by_loan_id(loan_id)
    where(seller_loan_number: loan_id)
  end

  def self.data_columns
    column_names
  end

  def credit_suisse_loan?
    smds_jumbo_fixed_loan.try(:credit_suisse?)
  end

end
