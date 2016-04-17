class UwSubmitDateException < DatabaseDatamartReadonly
  CREATE_VIEW_SQL = <<-eos
    SELECT
      v.LoanNum AS loan_id,
      SUBSTRING(v.Channel,1,2) AS channel,
      v.Borr1LastName AS borrower_last_name
    FROM
      LENDER_LOAN_SERVICE.[dbo].[vwLoan] v,
      LENDER_LOAN_SERVICE.[dbo].[CUSTOM_FIELD] cf
    WHERE
      cf.loanGeneral_Id = v.loanGeneral_Id
      AND cf.FormUniqueName = 'Submit File to UW'
      AND cf.AttributeUniqueName = 'UWSubmission'
      AND cf.AttributeValue = 'Y'
      AND v.PipelineLoanStatusDescription in
        ('New','U/W Pre-Approved','U/W Received','U/W Submitted','U/W Suspended')
      AND NOT EXISTS
        (SELECT 1
          FROM LENDER_LOAN_SERVICE.[dbo].[CUSTOM_FIELD] cf2
          WHERE
            cf2.loanGeneral_Id = cf.loanGeneral_Id
            AND cf2.FormUniqueName = cf.FormUniqueName
            AND cf2.AttributeUniqueName = cf.AttributeUniqueName
            AND cf2.InstanceSequence = 1
            AND cf2.AttributeValue = 'Y')
      AND NOT EXISTS
        (SELECT 1
          FROM LENDER_LOAN_SERVICE.[dbo].[ctm_Loan] cl2
          WHERE
            cl2.Loan_Num = v.LoanNum
            AND cl2.UW_Submit_Date IS NOT NULL
            AND cl2.UW_Submit_Date <> '')
  eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
