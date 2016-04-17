class AccountingScheduledFunding < DatabaseDatamartReadonly
  def self.sqlserver_create_view
    <<-eos
      SELECT v.LoanNum AS id,
             v.LoanNum AS loan_id,
             v.BorrLastName AS borrower_last_name,
             SUBSTRING(v.Channel,1,2) AS channel,
             SUBSTRING(v.LoanPurpose,1,4) AS loan_purpose,
              v.BranchID + ' - ' + v.[BranchName] AS branch,
              v.PropertyState AS property_state,
              v.LoanAmount AS loan_amount,
              v.DisbursementDate AS disbursement_date,
              v.[_FundedDate] AS funded_date,
              calc.[_Value] AS net_loan_disbursement,
              COALESCE(w.TotalAmount,0) AS total_disbursed_amount,
              calc.[_Value] - COALESCE(w.TotalAmount,0) AS variance,
              ca.[_UnparsedName] AS title_company,
              fd.[WarehouseBank] AS warehouse_bank,
              fd.WIBankName AS bank_name,
              fd.[WIBankABANumber] AS aba_number,
              fd.[WICreditAccountNumber] AS account_number,
              fd.[WIFurtherBankName] AS further_credit_to,
              fd.[WIFurtherBankABANumber] AS further_aba_number,
              fd.[WIFurtherCreditAccountNumber] AS further_account_number,
              fd.[WIFurtherReference] AS further_reference_number,
              fd.WIBankName2 AS bank2_name,
              fd.[WIBankABANumber2] AS bank2_aba_number,
              fd.[WIBankAccountNumber2] AS bank2_account_number
      FROM         LENDER_LOAN_SERVICE.dbo.vwLoanFact AS v
        INNER JOIN LENDER_LOAN_SERVICE.dbo.loan_general AS lg ON lg.LenderRegistrationIdentifier = v.LoanNum
        INNER JOIN LENDER_LOAN_SERVICE.dbo.FUNDING_DATA AS fd ON fd.loanGeneral_Id = lg.loanGeneral_Id
        INNER JOIN LENDER_LOAN_SERVICE.dbo.CLOSING_AGENT AS ca ON ca.loanGeneral_Id = lg.loanGeneral_Id AND ca._Type = 'TitleCompany'
        LEFT JOIN LENDER_LOAN_SERVICE.dbo.CALCULATION calc ON calc.loanGeneral_Id = lg.loanGeneral_Id AND calc.[_Name] = 'NetLoanDisbursementAmount'
        LEFT JOIN LENDER_LOAN_SERVICE.dbo.vwWireTotal w ON w.loanGeneral_Id = lg.loanGeneral_Id
      WHERE fd.[_RequestReceivedDate] IS NOT NULL AND v.CancelledPostponedDate IS NULL
    eos
  end
end
