class CreditSuisseLockFile < DatabaseDatamartReadonly

  def self.primary_key
    'seller_loan_number'
  end

  attr_accessor :event_type

  belongs_to :smds_jumbo_fixed_loan, :class_name => 'Smds::JumboFixedLoan', primary_key: 'loan_number', foreign_key: 'seller_loan_number'

  CREATE_VIEW_SQL = <<-eos
    SELECT -- event_type: provided by rails code (Lock, Re-lock, Re-activated, Cancel, Closed)
       L.LoanNum                   AS seller_loan_number,
       LLD.BorrowerFirstName       AS borrower1_first_name,
       LLD.BorrowerLastName        AS borrower1_last_name,
       LLD.BorrowerSSN             AS borrower1_ssn,
       LLD.CoBorrowerFirstName     AS borrower2_first_name,
       LLD.CoBorrowerLastName      AS borrower2_last_name,
       LLD.CoBorrowerSSN           AS borrower2_ssn,
       LLD.RepresentativeFICOScore AS credit_score,
       CASE UPPER(RTRIM(LLD.LoanPurposeType))
         WHEN 'PURCHASE'  THEN 'P'
         WHEN 'REFINANCE' THEN CASE UPPER(RTRIM(LLD.GSERefinancePurposeType))
                                 WHEN 'CASHOUTDEBTCONSOLIDATION' THEN 'CO'
                                 WHEN 'CASHOUTHOMEIMPROVEMENT'   THEN 'CO'
                                 WHEN 'CASHOUTLIMITED'           THEN 'RT'
                                 WHEN 'CASHOUTOTHER'             THEN 'CO'
                                 WHEN 'CHANGEINRATETERM'         THEN 'RT'
                                 ELSE NULL
                               END
         ELSE NULL
       END                         AS purpose_code,
       CASE UPPER(RTRIM(LLD.PropertyUsageType))
         WHEN 'INVESTOR'         THEN 'I'
         WHEN 'PRIMARYRESIDENCE' THEN 'P'
         WHEN 'SECONDHOME'       THEN 'S'
         ELSE NULL
       END                         AS occupancy_type,
       CASE UPPER(RTRIM(LLD.GSEPropertyType))
         WHEN 'ATTACHED'    THEN 'SFA'
         WHEN 'CONDOMINIUM' THEN CASE
                                   WHEN LLD.NumberOfStories BETWEEN 1 AND 4 THEN 'CLR'
                                   WHEN LLD.NumberOfStories BETWEEN 5 AND 8 THEN 'CMR'
                                   WHEN LLD.NumberOfStories > 8             THEN 'CHR'
                                   ELSE 'CONDO'
                                 END
         WHEN 'DETACHED'    THEN 'SFD'
         WHEN 'PUDDETACHED' THEN 'PUD'
         WHEN 'PUDATTACHED' THEN 'PUD'
         WHEN 'SITECONDO'   THEN 'CONDO'
         ELSE NULL
       END                         AS property_type,
       LLD.FinancedNumberOfUnits   AS number_of_units,
       LLD.PropertyStreetAddress   AS property_street,
       LLD.PropertyCity            AS property_city,
       LLD.PropertyState           AS property_state,
       LLD.PropertyPostalCode      AS property_zip,
       LLD.PurchasePriceAmount     AS property_purch_price,
       LLD.PropertyAppraisedValueAmount  AS property_appraised_value,
       LLD.TotalLoanAmount               AS original_loan_amount,
       LLD.LTV                           AS ltv,
       LLD.CLTV                          AS cltv,
       LLD.DebtToIncomeRatio             AS back_ratio,
       CASE LP.ProductCode
         WHEN 'J15FXD' THEN 'FXD15'
         WHEN 'J30FXD' THEN 'FXD30'
         ELSE NULL
       END                               AS product_type,
       CASE UPPER(RTRIM(LLD.LoanDocumentationType))
         WHEN 'FULLDOCUMENTATION' THEN 'FULL'
         ELSE NULL
       END                               AS document_type,
       CASE LEFT(L.LoanNum, 1)
         WHEN '1' THEN 'Retail'
         WHEN '4' THEN 'Consumer Direct'
         WHEN '6' THEN 'Wholesale'
         WHEN '8' THEN 'Mini-Correspondent/Reimbursement'
         ELSE NULL
       END                               AS origination_channel,
       LP.BaseRate                       AS note_rate,
       ISNULL(IL.ServicingFeePercent, 0) AS servicing_fee,
       LP.FinalNoteRate                  AS lender_net_rate,
       CONVERT(decimal(8,4), 0)          AS gross_margin, -- Does not apply to Jumbos; Hard-coded 0
       CONVERT(varchar, ISNULL(IL.InvestorLockDate, GETDATE()), 101)
                                         AS pricing_date,
       CONVERT(varchar, ISNULL(IL.InvestorLockDate, GETDATE()), 101)
                                         AS lock_date,
       ISNULL(LP.LockPeriod, 0) + 15     AS lock_term,
       CONVERT(varchar, ISNULL(IL.InvestorLockExpirationDate, DATEADD(D, ISNULL(LP.LockPeriod, 0) + 15, ISNULL(IL.InvestorLockDate, GETDATE()))), 101)
                                         AS lock_expr_date,
       CONVERT(smallint, 0)              AS extension_days,
       ISNULL(IL.GrossSellPrice, 0)      AS loan_price,
       ISNULL(IL.NetSellPrice, 0) - ISNULL(IL.GrossSellPrice, 0)
                                         AS price_adj,
       CONVERT(decimal(8,4), 0)          AS extension_fee,
       ISNULL(IL.NetSellPrice, 0)        AS net_price,
       CONVERT(varchar, LLD.EstimatedClosingDate, 101)
                                         AS estimated_close_date
    FROM LENDER_LOAN_SERVICE.dbo.vwLoan L
    INNER JOIN LENDER_LOAN_SERVICE.dbo.LOCK_LOAN_DATA LLD    ON L.loanGeneral_Id = LLD.loanGeneral_Id
    INNER JOIN LENDER_LOAN_SERVICE.dbo.LOCK_PRICE LP         ON L.loanGeneral_Id = LP.loanGeneral_Id
    LEFT OUTER JOIN LENDER_LOAN_SERVICE.dbo.INVESTOR_LOCK IL ON L.loanGeneral_Id = IL.loanGeneral_Id
  eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def self.by_loan_id(loan_id)
    where(seller_loan_number: loan_id)
  end

  def self.data_columns
    ['event_type'] + column_names
  end

  def event_options
    %w(Lock Re-Lock Re-Activated Cancel Closed)
  end

  def credit_suisse_loan?
    smds_jumbo_fixed_loan.try(:credit_suisse?)
  end


end
