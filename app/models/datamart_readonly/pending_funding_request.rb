class PendingFundingRequest < DatabaseDatamartReadonly
  def self.sqlserver_create_view
    <<-eos
      SELECT
        LENDER_LOAN_SERVICE.dbo.vwDMLoan.LoanNum                    AS id,
        LENDER_LOAN_SERVICE.dbo.vwDMLoan.LoanNum                    AS loan_id,
        LENDER_LOAN_SERVICE.dbo.vwDMLoan.Borr1LastName              AS borrower_last_name,
        LENDER_LOAN_SERVICE.dbo.FUNDING_DATA.[_RequestReceivedDate] AS request_received_at,
        LENDER_LOAN_SERVICE.dbo.LOAN_DETAILS.DisbursementDate       AS disbursed_at,
        LENDER_LOAN_SERVICE.dbo.LOAN_PURPOSE.[_Type]                AS loan_type
      FROM LENDER_LOAN_SERVICE.dbo.LOAN_PURPOSE
      INNER JOIN (
                   (
                     LENDER_LOAN_SERVICE.dbo.vwDMLoan
                     INNER JOIN LENDER_LOAN_SERVICE.dbo.FUNDING_DATA
                       ON LENDER_LOAN_SERVICE.dbo.vwDMLoan.loanGeneral_Id = LENDER_LOAN_SERVICE.dbo.FUNDING_DATA.loanGeneral_Id
                   )
                   INNER JOIN LENDER_LOAN_SERVICE.dbo.LOAN_DETAILS
                     ON LENDER_LOAN_SERVICE.dbo.vwDMLoan.loanGeneral_Id = LENDER_LOAN_SERVICE.dbo.LOAN_DETAILS.loanGeneral_Id
                 )
                 ON LENDER_LOAN_SERVICE.dbo.LOAN_PURPOSE.loanGeneral_Id = LENDER_LOAN_SERVICE.dbo.LOAN_DETAILS.loanGeneral_Id
      WHERE (((LENDER_LOAN_SERVICE.dbo.FUNDING_DATA.[_RequestReceivedDate]) Is Not Null)
      AND ((LENDER_LOAN_SERVICE.dbo.FUNDING_DATA.[_FundedDate]) Is Null)
      AND ((LENDER_LOAN_SERVICE.dbo.LOAN_DETAILS.CancelledPostponedDate) Is Null))
    eos
  end
end
