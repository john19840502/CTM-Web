class FilesToBeUnderwritten < DatabaseDatamartReadonly
  def self.sqlserver_create_view
    <<-eos
      SELECT     v.LoanNum_numeric AS id, SUBSTRING(lp._Type, 1, 9) AS purpose, SUBSTRING(v.Channel, 1, 6) AS channel, CONVERT(VARCHAR, cl.UW_Submit_Date, 111)
                            AS submitted_at, DATEDIFF(d, cl.UW_Submit_Date, GETDATE()) AS age, CONVERT(VARCHAR, CONVERT(DATE, cf.AttributeValue), 111) AS received_at,
                            v.LoanNum AS loan_num, SUBSTRING(v.Borr1LastName, 1, 24) AS borrower, SUBSTRING(mt.MortgageType, 1, 4) AS mortgage_type, SUBSTRING(ud.ProductCode, 1,
                            8) AS product_code, SUBSTRING(ud.UnderwriterName, 1, 15) AS underwriter_name, SUBSTRING(v.PipelineLoanStatusDescription, 1, 15) AS status
      FROM         LENDER_LOAN_SERVICE.dbo.vwLoan AS v INNER JOIN
                            LENDER_LOAN_SERVICE.dbo.MORTGAGE_TERMS AS mt ON v.PipelineLoanStatusDescription IN ('Error', 'Imported', 'New', 'Submit/Error', 'Submitted',
                            'U/W Received', 'U/W Submitted') AND mt.loanGeneral_Id = v.loanGeneral_Id INNER JOIN
                            LENDER_LOAN_SERVICE.dbo.UNDERWRITING_DATA AS ud ON ud.loanGeneral_Id = v.loanGeneral_Id INNER JOIN
                            LENDER_LOAN_SERVICE.dbo.LOAN_PURPOSE AS lp ON lp.loanGeneral_Id = v.loanGeneral_Id INNER JOIN
                            LENDER_LOAN_SERVICE.dbo.LOAN_FEATURES AS lf ON lf.loanGeneral_Id = v.loanGeneral_Id INNER JOIN
                            LENDER_LOAN_SERVICE.dbo.ctm_Loan AS cl ON cl.Loan_Num = v.LoanNum AND cl.UW_Submit_Date IS NOT NULL LEFT OUTER JOIN
                            LENDER_LOAN_SERVICE.dbo.CUSTOM_FIELD AS cf ON cf.loanGeneral_Id = v.loanGeneral_Id AND cf.FormUniqueName = 'Submit File to UW' AND
                            cf.InstanceSequence = 1 AND cf.AttributeUniqueName = 'UWSubmissionRcvd'
    eos
  end


end


