class ArmReport < DatabaseDatamartReadonly

  default_scope { order('uw_product_code, loan_num') }


  
  def self.sqlserver_create_view
    <<-eos
      SELECT 
          lg.LenderRegistrationIdentifier               AS loan_num,
          b._LastName                                   AS last_name, 
          ai.Channel                                    AS channel, 
          ud.ProductCode                                AS uw_product_code, 
          lf.ProductName                                AS ten_oh_three_product_name, 
          ald.PipelineLoanStatusDescription             AS pipeline_loan_status_description, 
          lp.LockExpirationDate                         AS lock_expiration_date,
          CASE isNull(SMDS.InitialCap,0) WHEN 0 THEN RA._FirstChangeCapRate ELSE SMDS.InitialCap END        AS first_cap_rate,
          CASE isNull(SMDS.IntervalCap,0) WHEN 0 THEN RA._SubsequentCapPercent ELSE SMDS.IntervalCap END    AS subsequent_cap_rate, 
          CASE isNull(SMDS.LifetimeCap,0) WHEN 0 THEN ra.LifetimeCapPercent ELSE SMDS.LifetimeCap END       AS life_time_cap_rate, 
          isNull(ra.FirstRateAdjustmentMonths,0)        AS first_rate_adjustment_months,
          isNull(ra.SubsequentRateAdjustmentMonths,0)   AS subsequent_rate_adjustment_months
        FROM  LENDER_LOAN_SERVICE.dbo.LOAN_GENERAL AS lg
          join  LENDER_LOAN_SERVICE.dbo.ACCOUNT_INFO AS ai on lg.loanGeneral_Id = ai.loanGeneral_Id and ai.Channel not like 'T%-Test %'
          join LENDER_LOAN_SERVICE.dbo.ADDITIONAL_LOAN_DATA AS ald ON lg.loanGeneral_Id = ald.loanGeneral_Id
          join LENDER_LOAN_SERVICE.dbo.BORROWER b on lg.loanGeneral_Id = b.loanGeneral_Id and b.BorrowerID = 'BRW1'
          left outer join LENDER_LOAN_SERVICE.dbo.UNDERWRITING_DATA ud on lg.loanGeneral_Id = ud.loanGeneral_Id
          left outer join LENDER_LOAN_SERVICE.dbo.LOAN_FEATURES lf on lg.loanGeneral_Id = lf.loanGeneral_Id 
          left outer join LENDER_LOAN_SERVICE.dbo.LOCK_PRICE lp on lg.loanGeneral_Id = lp.loanGeneral_Id
          left outer join LENDER_LOAN_SERVICE.dbo.RATE_ADJUSTMENT ra on lg.loanGeneral_Id = ra.loanGeneral_Id
          left outer join LENDER_LOAN_SERVICE.dbo.DENIAL_LETTER dl on lg.loanGeneral_Id = dl.loanGeneral_Id
          left outer join CTM.smds.SMDSCompassLoanDetails smds on lg.LenderRegistrationIdentifier = smds.LnNbr
        where dl._MailedDate is null and (ud.ProductCode like 'C%ARM%' or lf.ProductName like 'C%ARM%') 
        and (ald.PipelineLoanStatusDescription not in ('Purchased','Servicing','Cancelled','Withdrawn','Investor Suspended','Shipped to Investor','Shipping Received','Imported','New','Submitted') 
             or (ai.Channel not in ('W0-Wholesale Standard','R0-Reimbursement Standard') and ald.PipelineLoanStatusDescription = 'New'))
        and (lp.LockExpirationDate >= '1/1/2012' or lp.LockExpirationDate is null)
    eos
  end
end
