class GfeDetail < DatabaseDatamartReadonly
  belongs_to :loan_general

  def drools_translated_disclosure_method_type
    case self.gfe_disclosure_method_type
      when 'FaceToFace' then 'In Person'
      when 'ElectronicDisclosure' then 'E-Disclosure'
      when 'Fax' then 'FAX'
      when 'Mail' then 'US Mail'
      when 'OvernightDelivery' then 'Overnight Delivery'
      else nil
    end
  end


  CREATE_VIEW_SQL = <<-eos
      SELECT  GFE_DETAIL_id                                     AS id,
              loanGeneral_Id                                    AS loan_general_id,
              [ApplicationReceivedDate]                         AS application_received_date,
              [EarliestAdditionalFeeCollectionDate]             AS earliest_additional_fee_collection_date,
              [EarliestClosingDateAfterGFERedisclosure]         AS earliest_closing_date_after_gfe_redisclosure,
              [EarliestClosingDateAfterInitialGFEDisclosure]    AS earliest_closing_date_after_initial_gfe_disclosure,
              [GFEAllInsurEscrowed]                             AS gfe_all_insurance_escrowed,
              [GFEAllPropTaxEscrowed]                           AS gfe_all_prop_tax_escrowed,
              [GFECanLoanBalanceRise]                           AS gfe_can_loan_balance_rise,
              [GFECanMonthlyAmtRise]                            AS gfe_can_monthly_amount_rise_indicator,
              [GFEChangeMonth]                                  AS gfe_change_month,
              [GFEDisclosureDate]                               AS gfe_disclosure_date,
              [GFEDisclosureMethodType]                         AS gfe_disclosure_method_type,
              [GFEInterestRateAvailableThroughDate]             AS gfe_interest_rate_available_through_date,
              [GFEIntToContinue]                                AS gfe_intention_to_continue,
              [GFEMaxBalloonAmt]                                AS gfe_max_balloon_amount,
              [GFEMaxLoanBalance]                               AS gfe_max_loan_balance,
              [GFEMaxMonthlyAmt]                                AS gfe_max_monthly_amount,
              [GFEMaxPrepayPenaltyAmt]                          AS gfe_max_prepay_penalty_amount,
              [GFEMaxRate]                                      AS gfe_maximum_interest_rate,
              [GFEPrePayPenalty]                                AS gfe_prepay_penalty,
              [GFERateLockMinimumDaysPriorToSettlementCount]    AS gfe_rate_lock_minimum_days_prior_to_settlement_count,
              [GFERateLockPeriodDaysCount]                      AS gfe_rate_lock_period_days_count,
              [GFERedisclosureDate]                             AS gfe_redisclosure_date,
              [GFERedisclosureReasonDescription]                AS gfe_redisclosure_reason_description,
              [GFERisedMonthlyAmt]                              AS gfe_rised_monthly_amount,
              [GFESettlementChargesAvailableThroughDate]        AS gfe_settlement_charges_available_through_date,
              [InitialGFEDisclosureDate]                        AS initial_gfe_disclosure_date
      FROM       LENDER_LOAN_SERVICE.dbo.[GFE_DETAIL]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  alias_attribute :application_date, :application_received_date
  
  def application_received_date
    super.try(:to_date)
  end
end

# [GFEPrePayPenalty] [bit] NULL
# [GFEMaxPrepayPenaltyAmt] [money] NULL
# [GFEIntRateLS] [decimal](8, 4) NULL
# [GFEEstSettlementAmtLS] [money] NULL
# [GFEIntRateLI] [decimal](8, 4) NULL
# [GFEEstSettlementAmtLI] [money] NULL
# [GFEAllInsurEscrowed] [bit] NULL
# [GFECanLoanBalanceRise] [bit] NULL
# [GFEMaxLoanBalance] [money] NULL
# [GFEMaxBalloonAmt] [money] NULL
# [GFEMaxMonthlyAmt] [money] NULL
# [GFEMaxRate] [decimal](8, 4) NULL
# [GFECanMonthlyAmtRise] [bit] NULL
# [GFEChangeMonth] [int] NULL
# [GFERisedMonthlyAmt] [money] NULL
# [GFEIntToContinue] [bit] NULL
