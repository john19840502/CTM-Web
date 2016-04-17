class CreditSuisseFundingFile < DatabaseDatamartReadonly

  def self.primary_key
    'loan_number'
  end

  belongs_to :smds_jumbo_fixed_loan, :class_name => 'Smds::JumboFixedLoan', primary_key: 'loan_number', foreign_key: 'loan_number'

  CREATE_VIEW_SQL = <<-eos
    SELECT 
       CONVERT(int, '1000938')         AS primary_servicer, -- SPS MERS Org ID
       CONVERT(decimal(7,6), 0)        AS servicing_fee_percentage,
       CONVERT(decimal(5,2), 0)        AS servicing_fee_flat_amount,
       CONVERT(tinyint, 99)            AS servicing_advance_methodology,
       CONVERT(int, '1008808')         AS originator, -- CTM MERS Org ID
       CONVERT(varchar(4), 'UNK')      AS loan_group,
       CLD.LnNbr                       AS loan_number,
       CONVERT(tinyint,
         CASE UPPER(RTRIM(CLD.LnAmortType))
           WHEN 'ADJUSTABLERATE' THEN 2
           WHEN 'FIXED' THEN 1
           ELSE 99
         END)                          AS amortization_type,
       CONVERT(tinyint,
         CASE UPPER(RTRIM(CLD.LienPriority))
           WHEN 'FIRSTLIEN'  THEN  1
           WHEN 'SECONDLIEN' THEN  2
                             ELSE 99 -- Unknown
         END)                          AS lien_position,
       CONVERT(tinyint, 0)             AS heloc_indicator,
       CONVERT(tinyint,
         CASE UPPER(RTRIM(CLD.LnPurpose))
           WHEN 'PURCHASE' THEN CASE CLD.HomeownerPastThreeYearsFlg
                                  WHEN 'Y' THEN 7 -- Other-than-first-time Home Purchase
                                  WHEN 'N' THEN 6 -- First Time Home Purchase
                                  ELSE 99         -- Unavailable
                                END
           WHEN 'REFINANCE' THEN CASE UPPER(RTRIM(CLD.RefPurposeType))
                                   WHEN 'CASHOUTDEBTCONSOLIDATION' THEN 1 -- Cash Out: Debt Consolidation
                                   WHEN 'CASHOUTHOMEIMPROVEMENT'   THEN 2 -- Cash Out: Home Improvement/Renovation
                                   WHEN 'CASHOUTLIMITED'           THEN 4 -- Limited Cash-Out
                                   WHEN 'CASHOUTOTHER'             THEN 3 -- Cash Out: Other/Multi-purpose/Unknown purpose
                                   WHEN 'CHANGEINRATETERM'         THEN 9 -- Rate/Term Refinance: Lender initiated (8) or Borrower initiated (9)
                                   ELSE 99                                -- Unavailable
                                 END
           WHEN 'CONSTRUCTIONTOPERMANENT' THEN 10 -- Construction to Permanent
           ELSE 99                                -- Unavailable
         END)                          AS loan_purpose,
       CLD.CashOutAmt                  AS cash_out_amount,
       ISNULL(CLD.HUD801OrigFee, 0) + ISNULL(CLD.HUD802DiscFee, 0) + ISNULL(CLD.HUD813AdminFee, 0)
                                       AS total_origination_and_discount_points_amount,
       CONVERT(tinyint, 0)             AS covered_high_cost_loan_indicator,
       CONVERT(tinyint,
         CASE UPPER(RTRIM(CLD.RelocationLoanFlag))
           WHEN 'N' THEN 0
           WHEN 'Y' THEN 1
           ELSE 99
         END)                          AS relocation_loan_indicator,
       CONVERT(tinyint,
         CASE LEFT(LTRIM(CLD.LnNbr), 1)
           WHEN '1' THEN  0 -- No  (Retail)
           WHEN '4' THEN  0 -- No  (Consumer Direct)
           WHEN '6' THEN  1 -- Yes (Wholesale)
           WHEN '8' THEN  1 -- Yes (Mini-Correspondent/Reimbursement)
                    ELSE 99 -- Unknown
         END)                          AS broker_indicator,
       CONVERT(tinyint,
         CASE LEFT(LTRIM(CLD.LnNbr), 1)
           WHEN '1' THEN  1 -- Retail
           WHEN '4' THEN  1 -- Retail (Consumer Direct)
           WHEN '6' THEN  2 -- Broker (Wholesale)
           WHEN '8' THEN  2 -- Broker (Mini-Correspondent/Reimbursement)
                    ELSE 99 -- Unknown
         END)                          AS channel,
       CONVERT(tinyint,
         CASE CLD.EscrowWaiverFlg
           WHEN 'Y' THEN  0 -- No Escrows
           WHEN 'N' THEN  4 -- Taxes and Insurance
                    ELSE 99 -- Unknown
         END)                          AS escrow_indicator,
       CONVERT(money, 0)               AS senior_loan_amounts,
       CONVERT(tinyint, 99)            AS loan_type_of_most_senior_lien,
       CONVERT(smallint, 0)            AS hybrid_period_of_most_senior_lien,
       CONVERT(decimal(7,6), 0)        AS neg_am_limit_of_most_senior_lien,
       CLD.SubordinateFinance          AS junior_mortgage_balance,
       '19010101'                      AS origination_date_of_most_senior_lien,
       CONVERT(varchar, ISNULL(CLD.ClsgDt, ISNULL(CLD.RlcExpectClsgDt, '1/1/1901')), 112)
                                       AS origination_date,
       CLD.LnAmt                       AS original_loan_amount,
       CONVERT(decimal(7,6), ISNULL(CLD.FinalNoteRate, 0) / 100)
                                       AS original_interest_rate,
       CLD.LnAmortTerm                 AS original_amortization_term,
       CLD.LnMaturityTerm              AS original_term_to_maturity,
       CONVERT(varchar, ISNULL(CLD.FirstPmtDt, '1/1/1901'), 112)
                                       AS first_payment_date_of_loan,
       CONVERT(tinyint, 99)            AS interest_type_indicator,
       CLD.InterestOnlyTerm            AS original_interest_only_term,
       CONVERT(smallint, 0)            AS buy_down_period,
       NULL                            AS heloc_draw_period,
       CLD.UPB                         AS current_loan_amount,
       CONVERT(decimal(7,6), ISNULL(CLD.FinalNoteRate, 0) / 100)
                                       AS current_interest_rate,
       CLD.[PI]                        AS current_payment_amount_due,
       CONVERT(varchar, ISNULL(CLD.IntPaidThruDt, '1/1/1901'), 112)
                                       AS interest_paid_through_date,
       CONVERT(tinyint, 0)             AS current_payment_status,
       /*** BEGIN: ARMs only *********************************************************************/
       CONVERT(tinyint, 99) AS index_type,
       CONVERT(tinyint, 0)             AS arm_look_back_days,
       CONVERT(decimal(7,6), ISNULL(CLD.MarginPct, 0) / 100)
                                       AS gross_margin,
       CONVERT(tinyint, 99)            AS arm_round_flag,
       CONVERT(decimal(7,6), 0)        AS arm_round_factor,
       CONVERT(smallint, 0)            AS initial_fixed_rate_period, -- Hybrid ARMs only
       CONVERT(decimal(7,6), 0)        AS initial_interest_rate_cap_change_up,
       CONVERT(decimal(7,6), 0)        AS initial_interest_rate_cap_change_down,
       CONVERT(smallint, 0)            AS subsequent_interest_rate_reset_period,
       CONVERT(decimal(7,6), 0)        AS subsequent_interest_rate_cap_change_down,
       CONVERT(decimal(7,6), 0)        AS subsequent_interest_rate_cap_change_up,
       CONVERT(decimal(7,6), 0)        AS lifetime_maximum_rate_ceiling,
       CONVERT(decimal(7,6), 0)        AS lifetime_minimum_rate_floor,
       /*** BEGIN: Negatively Amortizing ARMs Only *************************************************/
       CONVERT(decimal(7,6), 0)        AS negative_amortization_limit,
       CONVERT(smallint, 0)            AS initial_negative_amortization_recast_period,
       CONVERT(smallint, 0)            AS subsequent_negative_amortization_recast_period,
       CONVERT(smallint, 0)            AS initial_fixed_payment_period,
       CONVERT(smallint, 0)            AS subsequent_payment_reset_period,
       CONVERT(decimal(7,6), 0)        AS initial_periodic_payment_cap,
       CONVERT(decimal(7,6), 0)        AS subsequent_periodic_payment_cap,
       CONVERT(smallint, 0)            AS initial_minimum_payment_reset_period,
       CONVERT(smallint, 0)            AS subsequent_minimum_payment_reset_period,
       /*** END:   Negatively Amortizing ARMs Only *************************************************/
       CONVERT(tinyint, 99)            AS option_arm_indicator,
       /*** BEGIN: Option ARMs Only ****************************************************************/
       CONVERT(tinyint, 99)            AS options_at_recast,
       CONVERT(money, 0)               AS initial_minimum_payment,
       CONVERT(money, 0)               AS current_minimum_payment,
       /*** END    Option ARMs Only ****************************************************************/
       /*** END:   ARMs only ***********************************************************************/
       CONVERT(tinyint, 0)             AS prepayment_penalty_calculation,
       CONVERT(tinyint, 99)            AS prepayment_penalty_type,
       CONVERT(smallint, 0)            AS prepayment_penalty_total_term,
       CONVERT(smallint, 0)            AS prepayment_penalty_hard_term,
       CLD.Brw1SSN                     AS primary_borrower_id,
       CLD.NbrFinancedProperties       AS number_of_mortgaged_properties,
       CLD.NbrOfBrw                    AS total_number_of_borrowers,
       CONVERT(tinyint, CASE CLD.SelfEmpFlg
                          WHEN 'N' THEN 0
                          WHEN 'Y' THEN 1
                          ELSE 99
                        END)           AS self_employment_flag,
       CLD.MonthlyOtherExp             AS current_other_monthly_payment,
       CONVERT(decimal(4,2), CONVERT(decimal, ISNULL(CLD.Brw1MonthsEmployed, 0)) / 12)
                                       AS length_of_employment_borrower,
       CONVERT(decimal(4,2), CONVERT(decimal, ISNULL(CLD.Brw2MonthsEmployed, 0)) / 12)
                                       AS length_of_employment_coborrower,
       CONVERT(decimal(4,2), CONVERT(decimal, ISNULL(CLD.Brw1MthsAtCurrAddr, 0)) / 12)
                                       AS years_in_home,
       CONVERT(tinyint, 99)            AS fico_model_used,
       '19010101'                      AS most_recent_fico_date,
       CONVERT(smallint,
         CASE
           WHEN CHARINDEX('equifax', LOWER(CLD.Brw1CreditScoreSource)) > 0 THEN CLD.Brw1CreditScore
           ELSE 0
         END)                          AS primary_wage_earner_original_fico_equifax,
       CONVERT(smallint,
         CASE
           WHEN CHARINDEX('experian', LOWER(CLD.Brw1CreditScoreSource)) > 0 THEN CLD.Brw1CreditScore
           ELSE 0
         END)                          AS primary_wage_earner_original_fico_experian,
       CONVERT(smallint,
         CASE
           WHEN CHARINDEX('transunion', LOWER(CLD.Brw1CreditScoreSource)) > 0 THEN CLD.Brw1CreditScore
           ELSE 0
         END)                          AS primary_wage_earner_original_fico_transunion,
       CONVERT(smallint,
         CASE
           WHEN CHARINDEX('equifax', LOWER(CLD.Brw2CreditScoreSource)) > 0 THEN CLD.Brw2CreditScore
           ELSE 0
         END)                          AS secondary_wage_earner_original_fico_equifax,
       CONVERT(smallint,
         CASE
           WHEN CHARINDEX('experian', LOWER(CLD.Brw2CreditScoreSource)) > 0 THEN CLD.Brw2CreditScore
           ELSE 0
         END)                          AS secondary_wage_earner_original_fico_experian,
       CONVERT(smallint,
         CASE
           WHEN CHARINDEX('transunion', LOWER(CLD.Brw2CreditScoreSource)) > 0 THEN CLD.Brw2CreditScore
           ELSE 0
         END)                          AS secondary_wage_earner_original_fico_transunion,
       CLD.Brw1CreditScore             AS most_recent_primary_borrower_fico,
       CLD.Brw2CreditScore             AS most_recent_coborrower_fico,
       CONVERT(tinyint, 3)             AS most_recent_fico_method,
       CONVERT(smallint, 0)            AS vantagescore_primary_borrower,
       CONVERT(smallint, 0)            AS vantagescore_coborrower,
       CONVERT(tinyint, 0)             AS most_recent_vantagescore_method,
       '19010101'                      AS vantagescore_date,
       CONVERT(smallint, 0)            AS credit_report_longest_trade_line,
       CONVERT(money, 0)               AS credit_report_maximum_trade_line,
       CONVERT(smallint, 0)            AS credit_report_number_of_trade_lines,
       CONVERT(decimal(7,6), 0)        AS credit_line_usage_ratio,
       REPLICATE('X', 12)              AS most_recent_12_month_pay_history,
       CONVERT(smallint, 0)            AS months_bankruptcy,
       CONVERT(smallint, 0)            AS months_foreclosure,
       CLD.Brw1MonthlyIncomeBase       AS primary_borrower_wage_income,
       CLD.Brw2MonthlyIncomeBase       AS coborrower_wage_income,
       CLD.Brw1MonthlyIncomeOther      AS primary_borrower_other_income,
       CLD.Brw2MonthlyIncomeOther      AS coborrower_other_income,
       CLD.MonthlyIncomeBase           AS all_borrower_wage_income,
       CLD.MonthlyIncome               AS all_borrower_total_income,
       CONVERT(tinyint, 1)             AS transcript_of_tax_return_indicator,
       CONVERT(tinyint, 5)             AS borrower_income_verification_level,
       CONVERT(tinyint, CASE WHEN CLD.NbrOfBrw > 1 THEN 5 ELSE NULL END)
                                       AS coborrower_income_verification,
       CONVERT(tinyint, 3)             AS borrower_employment_verification,
       CONVERT(tinyint, CASE WHEN CLD.NbrOfBrw > 1 THEN 3 ELSE NULL END)
                                       AS coborrower_employment_verification,
       CONVERT(tinyint, 4)             AS borrower_asset_verification,
       CONVERT(tinyint, CASE WHEN CLD.NbrOfBrw > 1 THEN 4 ELSE NULL END)
                                       AS coborrower_asset_verification,
       CLD.ReservesAmt                 AS liquid_cash_reserves,
       CLD.MonthlyDebtExp              AS monthly_debt_all_borrowers,
       CONVERT(decimal(8,6), ISNULL(CLD.DTI, 0) / 100)
                                       AS originator_dti,
       CONVERT(decimal(7,6), 0)        AS fully_indexed_rate, -- ARMs only
       CONVERT(tinyint, 99)            AS qualification_method,
       CONVERT(decimal(7,6), 0)        AS percentage_of_down_payment_from_borrower_own_funds,
       CLD.PropertyCity                AS property_city,
       CLD.PropertyState               AS property_state, -- Appendix H
       CLD.PropertyPostalCode          AS property_postal_code,
       CONVERT(tinyint,
         CASE UPPER(RTRIM(CLD.PropertyType))
           WHEN 'ATTACHED'    THEN CASE CLD.NbrOfUnits
                                     WHEN 1 THEN 12 -- 1 Family Attached
                                     WHEN 2 THEN 13 -- 2 Family
                                     WHEN 3 THEN 14 -- 3 Family
                                     WHEN 4 THEN 15 -- 4 Family
                                     ELSE 12
                                   END
           WHEN 'CONDOMINIUM' THEN CASE
                                     WHEN CLD.NbrOfStories BETWEEN 1 AND 4 THEN 3 -- Condo, Low Rise (4 or fewer stories)
                                     WHEN CLD.NbrOfStories > 4             THEN 4 -- Condo, High Rise (5+ stories)
                                     ELSE 3
                                   END
           WHEN 'DETACHED'    THEN CASE CLD.NbrOfUnits
                                     WHEN 1 THEN 1  -- Single Family Detached (non-PUD)
                                     WHEN 2 THEN 13 -- 2 Family
                                     WHEN 3 THEN 14 -- 3 Family
                                     WHEN 4 THEN 15 -- 4 Family
                                     ELSE 1
                                   END
           WHEN 'PUDATTACHED' THEN 12 -- 1 Family Attached
           WHEN 'PUDDETACHED' THEN CASE CLD.NbrOfUnits
                                     WHEN 1 THEN 7  -- PUD (Only for use with Single-Family Detached Homes with PUD riders)
                                     WHEN 2 THEN 13 -- 2 Family
                                     WHEN 3 THEN 14 -- 3 Family
                                     WHEN 4 THEN 15 -- 4 Family
                                     ELSE 7
                                   END
           WHEN 'MODULAR'     THEN 98 -- Other
           WHEN 'SITECONDO'   THEN 1  -- Single Family Detached (non-PUD)
           ELSE 99 -- Unavailable
         END)                          AS property_type, -- Appendix D
       CONVERT(tinyint,
         CASE UPPER(RTRIM(CLD.PropertyOccupy))
           WHEN 'INVESTOR'         THEN 3 -- Investment Property
           WHEN 'PRIMARYRESIDENCE' THEN 1 -- Owner-occupied
           WHEN 'SECONDHOME'       THEN 2 -- Second Home
           ELSE 99 -- Unavailable
         END)                          AS occupancy_code, -- Appendix E
       CLD.SalePrice                   AS sales_price,
       CLD.AppraisdValue               AS original_appraised_property_value,
       CONVERT(tinyint,
         CASE
           WHEN LEFT(CLD.FieldworkObtained, 9) IN('Form 1004', 'Form 1025',
                                                  'Form 1073', 'Form 2090') THEN 3
           WHEN LEFT(CLD.FieldworkObtained, 9) IN('Form 2070', 'Form 2075') THEN 4
           WHEN LEFT(CLD.FieldworkObtained, 9) IN('Form 1075', 'Form 2055') THEN 5
           WHEN LEFT(CLD.FieldworkObtained, 12) = 'No appraisal'            THEN 8  -- No Appraisal/Stated Value
           WHEN RTRIM(CLD.FieldworkObtained) = 'Other' OR
                LEN(RTRIM(CLD.FieldworkObtained)) > 0                       THEN 98 -- Other
           ELSE 99 -- Unavailable
         END)                          AS original_property_valuation_type, -- Appendix F
       CONVERT(varchar, ISNULL(CLD.AppraisalDt, '1/1/1901'), 112)
                                       AS original_property_valuation_date,
       CONVERT(tinyint,
         CASE UPPER(RTRIM(CLD.AVMModelName))
           WHEN 'HOMEVALUEEXPLORER' THEN 5 -- HVE (Freddie Mac)
           ELSE 0
         END)                          AS original_avm_model_name, -- Appendix I
       CONVERT(decimal(7,6), 0)        AS original_avm_confidence_score,
       CONVERT(money, 0)               AS most_recent_property_value,
       CONVERT(tinyint,
         CASE
           WHEN LEFT(CLD.FieldworkObtained, 9) IN('Form 1004', 'Form 1025',
                                                  'Form 1073', 'Form 2090') THEN 3
           WHEN LEFT(CLD.FieldworkObtained, 9) IN('Form 2070', 'Form 2075') THEN 4
           WHEN LEFT(CLD.FieldworkObtained, 9) IN('Form 1075', 'Form 2055') THEN 5
           WHEN LEFT(CLD.FieldworkObtained, 12) = 'No appraisal'            THEN 8  -- No Appraisal/Stated Value
           WHEN RTRIM(CLD.FieldworkObtained) = 'Other' OR
                LEN(RTRIM(CLD.FieldworkObtained)) > 0                       THEN 98 -- Other
           ELSE 99 -- Unavailable
         END)                          AS most_recent_property_valuation_type, -- Appendix F
       CONVERT(varchar, ISNULL(CLD.AppraisalDt, '1/1/1901'), 112)
                                       AS most_recent_property_valuation_date,
       CONVERT(tinyint,
         CASE UPPER(RTRIM(CLD.AVMModelName))
           WHEN 'HOMEVALUEEXPLORER' THEN 5 -- HVE (Freddie Mac)
           ELSE 0
         END)                          AS most_recent_avm_model_name, -- Appendix I
       CONVERT(decimal(7,6), 0)        AS most_recent_avm_confidence_score,
       CONVERT(decimal(7,6), ISNULL(LLD.CLTV, 0) / 100)
                                       AS original_cltv,
       CONVERT(decimal(7,6), ISNULL(LLD.LTV , 0) / 100)
                                       AS original_ltv,
       CONVERT(money, 0)               AS original_pledged_assets,
       CONVERT(tinyint,
         CASE UPPER(RTRIM(ISNULL(CLD.MICompanyName, '')))
           WHEN 'ESSENT GUARANTY'    THEN 98 -- Other ?
           WHEN 'GE'                 THEN 28 -- General Electric Residential Mortgage Insurance Co.
           WHEN 'GENWORTH FINANCIAL' THEN 1  -- Genworth
           WHEN 'MGIC'               THEN 4  -- Mortgage Guaranty Insurance Corp.
           WHEN 'PMI'                THEN 7  -- PMI Mortgage Insurance Co.
           WHEN 'RADIAN'             THEN 24 -- Radian Insurance Inc.
           WHEN 'RMIC'               THEN 9  -- Republic Mortgage Insurance Co.
           WHEN 'UNITED GUARANTY'    THEN 8  -- United Guaranty Insurance Corp.
           ELSE 99 -- Unavailable
           -- 0 = No MI
         END)                          AS mortgage_insurance_company_name, -- Appendix G
       CONVERT(decimal(7,6), ISNULL(CLD.MiCoveragePct, 0) / 100)
                                       AS mortgage_insurance_percent,
       CONVERT(tinyint, CASE CLD.LenderPaidMiFlg
                          WHEN 'N' THEN 1 -- Borrower-Paid
                          WHEN 'Y' THEN 2 -- Lender-Paid
                          ELSE 99 -- Unknown
                        END)           AS mortgage_insurance_lender_or_borrower_paid,
       CONVERT(tinyint, 99)            AS pool_insurance_co_name, -- Appendix G
       CONVERT(decimal(7,6), 0)        AS pool_insurance_stop_loss_percentage,
       CASE CLD.MICertNbr
         WHEN 'NA' THEN 'UNK'
         ELSE LEFT(LTRIM(CLD.MICertNbr), 20)
       END                             AS mortgage_insurance_certificate_number,
       /*** BEGIN: Pertains only to loans modified for loss mitigation purposes ******************/
       CONVERT(decimal(7,6), 0)        AS updated_dti_front_end,
       CONVERT(decimal(7,6), 0)        AS updated_dti_back_end,
       '19010101'                      AS modification_effective_payment_date,
       CONVERT(money, 0)               AS total_capitalized_amount,
       CONVERT(money, 0)               AS total_deferred_amount,
       CONVERT(decimal(7,6), 0)        AS pre_modification_interest_note_rate,
       CONVERT(money, 0)               AS pre_modification_principal_and_interest_payment,
       CONVERT(decimal(7,6), 0)        AS pre_modification_initial_interest_rate_change_downward_cap,
       CONVERT(decimal(7,6), 0)        AS pre_modification_subsequent_interest_rate_cap,
       '19010101'                      AS pre_modification_next_interest_rate_change_date,
       CONVERT(smallint, 0)            AS pre_modification_interest_only_term,
       CONVERT(money, 0)               AS forgiven_principal_amount,
       CONVERT(money, 0)               AS forgiven_interest_amount,
       CONVERT(tinyint, 0)             AS number_of_modifications,
       /*** END:   Pertains only to loans modified for loss mitigation purposes ******************/
       /*** BEGIN: Manufactured Housing Loans Only ***********************************************/
       CONVERT(tinyint, 99)            AS real_estate_interest,
       CONVERT(tinyint, 99)            AS community_ownership_structure,
       '1901'                          AS year_of_manufacture,
       CONVERT(tinyint, 99)            AS hud_code_compliance_indicator,
       CONVERT(money, 0)               AS gross_manufacturer_invoice_price,
       CONVERT(decimal(7,6), 0)        AS loan_to_invoice_gross,
       CONVERT(money, 0)               AS net_manufacturer_invoice_price,
       CONVERT(decimal(7,6), 0)        AS loan_to_invoice_net,
       NULL                            AS manufacturer_name,
       NULL                            AS model_name,
       CONVERT(tinyint, 99)            AS down_payment_source,
       CONVERT(tinyint, 99)            AS community_related_party_lender,
       CONVERT(tinyint, 99)            AS defined_underwriting_criteria,
       CONVERT(tinyint, 99)            AS chattel_indicator
       /*** END:   Manufactured Housing Loans Only ***********************************************/
    FROM CTM.smds.SMDSCompassLoanDetails CLD
    INNER JOIN LENDER_LOAN_SERVICE.dbo.vwLoan L ON CLD.LnNbr = L.LoanNum
    INNER JOIN LENDER_LOAN_SERVICE.dbo.LOCK_LOAN_DATA LLD ON L.loanGeneral_Id = LLD.loanGeneral_Id
  eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def self.by_loan_id(loan_id)
    where(loan_number: loan_id)
  end

  def self.data_columns
    column_names
  end

  def credit_suisse_loan?
    smds_jumbo_fixed_loan.try(:credit_suisse?)
  end

end
