class TestLoan < Loan
  self.table_name = "#{table_name_prefix}test_loans#{table_name_suffix}"

  CREATE_VIEW_SQL = <<-eos
SELECT        lg.LenderRegistrationIdentifier AS id,
              lg.LenderRegistrationIdentifier AS loan_num,
              mterms.BorrowerRequestedLoanAmount AS loan_amount,
              prop._StreetAddress + ' ' + prop._StreetAddressUnit AS property_street,
              prop._State AS property_state,
              prop._City AS property_city,
              prop._County AS property_county,
              prop._PostalCode AS property_zip,
              txmit.PropertyAppraisedValueAmount AS appraised_value,
              b._LastName AS borrower_last_name,
              b._FirstName AS borrower_first_name,
              acctinfo.Channel AS channel,
              cdti._Value AS debt_to_income_ratio,
              lfeat.EscrowWaiverIndicator AS is_escrow_waived,
              fund._FundedDate AS funded_at,
              acctg.PurchasedByInvestorDate AS purchased_by_investor_at,
              b._ApplicationSignedDate AS signed_1003_at,
              CAST(CONVERT(nvarchar, lkprice.LockDate, 101) AS datetime) AS locked_at,
              CAST(CONVERT(nvarchar, lkprice.LockExpirationDate, 101) AS datetime) AS lock_expiration_at,
              CAST(CASE WHEN acctinfo.Channel LIKE 'R%' AND fund._FundedDate IS NULL
                         THEN 0 WHEN alnd.pipelineloanstatusdescription IN ('Funded', 'Investor Suspended', 'Purchased', 'Shipped to Investor', 'Shipping Received', 'Servicing')
                         THEN 1 WHEN alnd.pipelineloanstatusdescription = 'Closed' THEN CASE WHEN ldet.ClosingDate = fund._FundedDate THEN 1 ELSE 0 END WHEN alnd.pipelineloanstatusdescription
                          = 'Docs Out' THEN CASE WHEN ldet.DocumentOutDate <= fund._FundedDate + 1 THEN 1 ELSE 0 END WHEN alnd.pipelineloanstatusdescription = 'Funding Request Received'
                          THEN CASE WHEN LENDER_LOAN_SERVICE.dbo.fxTruncDate(fund._RequestReceivedDate, 'd') <= fund._FundedDate THEN 1 ELSE 0 END ELSE 0 END AS bit) AS is_funded,
              CAST(CASE WHEN acctg.PurchasedByInvestorDate IS NULL THEN 0 ELSE 1 END AS bit) AS is_sold,
              CASE WHEN acctg.PurchasedByInvestorDate IS NULL THEN 0 ELSE mterms.BorrowerRequestedLoanAmount END AS sold_loan_amount,
              alnd.PipelineLoanStatusDescription AS loan_status,
              ldet.DisbursementDate AS disbursed_at,
              ldet.ClosingDate AS closed_at,
              ilock.InvestorName AS investor_name,
              alnd.AccountExecutiveName AS area_manager,
              cln.UW_Submit_Date AS submit_to_underwriting_date,
              cln.UW_Initial_Decision_Date as initial_decision_date,
              CAST(CONVERT (nvarchar, ISNULL(uw._FinalApprovalReadyForDocsDate, uw._FinalApprovalDate), 101) AS datetime) as final_approval_date,
              lkprice.FinalNoteRate as final_note_rate,
              lkprice.NetPrice as net_price
FROM            LENDER_LOAN_SERVICE.dbo.LOAN_GENERAL AS lg INNER JOIN
                         LENDER_LOAN_SERVICE.dbo.ACCOUNT_INFO AS acctinfo ON lg.loanGeneral_Id = acctinfo.loanGeneral_Id INNER JOIN
                         LENDER_LOAN_SERVICE.dbo.ADDITIONAL_LOAN_DATA AS alnd ON lg.loanGeneral_Id = alnd.loanGeneral_Id INNER JOIN
                         LENDER_LOAN_SERVICE.dbo.BORROWER AS b ON lg.loanGeneral_Id = b.loanGeneral_Id INNER JOIN
                        LENDER_LOAN_SERVICE.dbo.CALCULATION AS cdti ON lg.loanGeneral_Id = cdti.loanGeneral_Id AND cdti._Name = 'TotalObligationsIncomeRatio' INNER JOIN
                        LENDER_LOAN_SERVICE.dbo.INVESTOR_LOCK AS ilock ON lg.loanGeneral_Id = ilock.loanGeneral_Id INNER JOIN
                        LENDER_LOAN_SERVICE.dbo.LOAN_DETAILS AS ldet ON lg.loanGeneral_Id = ldet.loanGeneral_Id INNER JOIN
                        LENDER_LOAN_SERVICE.dbo.LOAN_FEATURES AS lfeat ON lg.loanGeneral_Id = lfeat.loanGeneral_Id INNER JOIN
                        LENDER_LOAN_SERVICE.dbo.LOAN_PURPOSE AS lpurp ON lg.loanGeneral_Id = lpurp.loanGeneral_Id INNER JOIN
                        LENDER_LOAN_SERVICE.dbo.MORTGAGE_TERMS AS mterms ON lg.loanGeneral_Id = mterms.loanGeneral_Id INNER JOIN
                        LENDER_LOAN_SERVICE.dbo.PROPERTY AS prop ON lg.loanGeneral_Id = prop.loanGeneral_Id INNER JOIN
                        LENDER_LOAN_SERVICE.dbo.TRANSACTION_DETAIL AS txdet ON lg.loanGeneral_Id = txdet.loanGeneral_Id INNER JOIN
                        LENDER_LOAN_SERVICE.dbo.TRANSMITTAL_DATA AS txmit ON lg.loanGeneral_Id = txmit.loanGeneral_Id INNER JOIN
                        LENDER_LOAN_SERVICE.dbo.UNDERWRITING_DATA AS uw ON lg.loanGeneral_Id = uw.loanGeneral_Id LEFT OUTER JOIN
                        LENDER_LOAN_SERVICE.dbo.INSTITUTION AS inst ON acctinfo.InstitutionIdentifier = inst.InstitutionNumber LEFT OUTER JOIN
                        LENDER_LOAN_SERVICE.dbo.ctm_Loan AS cln ON lg.LenderRegistrationIdentifier = cln.Loan_Num LEFT OUTER JOIN
                        LENDER_LOAN_SERVICE.dbo.FUNDING_DATA AS fund ON lg.loanGeneral_Id = fund.loanGeneral_Id LEFT OUTER JOIN
                        LENDER_LOAN_SERVICE.dbo.SHIPPING AS ship ON lg.loanGeneral_Id = ship.loanGeneral_Id LEFT OUTER JOIN
                        LENDER_LOAN_SERVICE.dbo.DENIAL_LETTER AS den ON lg.loanGeneral_Id = den.loanGeneral_Id LEFT OUTER JOIN
                        LENDER_LOAN_SERVICE.dbo.ACCOUNTING AS acctg ON lg.loanGeneral_Id = acctg.loanGeneral_Id LEFT OUTER JOIN
                        LENDER_LOAN_SERVICE.dbo.LOCK_PRICE AS lkprice ON lg.loanGeneral_Id = lkprice.loanGeneral_Id
WHERE        (lg.loanStatus = 20) AND (b.BorrowerID = 'BRW1') AND ((acctinfo.InstitutionName LIKE 'TEST%') OR (acctinfo.InstitutionIdentifier = 'Avista') OR (acctinfo.InstitutionIdentifier = 'Mortgagebot'))
  eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end