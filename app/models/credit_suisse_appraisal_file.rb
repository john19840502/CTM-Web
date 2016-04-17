class CreditSuisseAppraisalFile < DatabaseDatamartReadonly

  def self.primary_key
    'lender_loan_number'
  end

  belongs_to :smds_jumbo_fixed_loan, :class_name => 'Smds::JumboFixedLoan', primary_key: 'loan_number', foreign_key: 'lender_loan_number'

  CREATE_VIEW_SQL = <<-eos
    SELECT CLD.LnNbr                  AS lender_loan_number,
       CLD.Brw1LName              AS borrower1_last_name,
       CASE UPPER(RTRIM(CLD.LnPurpose))
         WHEN 'PURCHASE'  THEN 'P'
         WHEN 'REFINANCE' THEN CASE UPPER(RTRIM(CLD.RefPurposeType))
                                 WHEN 'CASHOUTDEBTCONSOLIDATION' THEN 'CO'
                                 WHEN 'CASHOUTHOMEIMPROVEMENT'   THEN 'CO'
                                 WHEN 'CASHOUTLIMITED'           THEN 'RT'
                                 WHEN 'CASHOUTOTHER'             THEN 'CO'
                                 WHEN 'CHANGEINRATETERM'         THEN 'RT'
                                 ELSE NULL
                               END
         ELSE NULL
       END                       AS purpose_code,
       CASE UPPER(RTRIM(CLD.PropertyOccupy))
         WHEN 'INVESTOR'         THEN 'I'
         WHEN 'PRIMARYRESIDENCE' THEN 'P'
         WHEN 'SECONDHOME'       THEN 'S'
         ELSE NULL
       END                       AS occupancy_code,
       CASE UPPER(RTRIM(CLD.PropertyType))
         WHEN 'ATTACHED'    THEN 'SFA'
         WHEN 'CONDOMINIUM' THEN CASE
                                   WHEN CLD.NbrOfStories BETWEEN 1 AND 4 THEN 'CLR'
                                   WHEN CLD.NbrOfStories BETWEEN 5 AND 8 THEN 'CMR'
                                   WHEN CLD.NbrOfStories > 8             THEN 'CHR'
                                   ELSE 'CONDO'
                                 END
         WHEN 'DETACHED'    THEN 'SFD'
         WHEN 'PUDDETACHED' THEN 'PUD'
         WHEN 'PUDATTACHED' THEN 'PUD'
         WHEN 'SITECONDO'   THEN 'CONDO'
         ELSE NULL
       END                       AS property_code,
       CLD.NbrOfUnits            AS number_of_units,
       CLD.PropertyStreetAddress AS property_address,
       NULL                      AS property_address2,
       CLD.PropertyCity          AS property_city,
       CLD.PropertyState         AS property_state,
       CLD.PropertyPostalCode    AS property_zip,
       CLD.SalePrice             AS sales_price,
       CLD.AppraisdValue         AS appraised_value,
       CLD.LnAmt                 AS original_loan_amount,
       CLD.LTV                   AS ltv,
       CLD.CLTV                  AS cltv,
       CONVERT(varchar, CLD.RlcExpectClsgDt, 101)
                                 AS estimated_close_date
    FROM CTM.smds.SMDSCompassLoanDetails CLD
  eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def self.by_loan_id(loan_id)
    where(lender_loan_number: loan_id)
  end

  def self.data_columns
    column_names
  end

  def credit_suisse_loan?
    smds_jumbo_fixed_loan.try(:credit_suisse?)
  end

end
