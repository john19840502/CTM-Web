class CondSubmittedNotReceived < DatabaseDatamartReadonly
  def self.sqlserver_create_view
    <<-eos
       SELECT v.loanGeneral_Id AS id,
           SUBSTRING(v.Channel,1,2) AS channel,
           SUBSTRING(lp._Type,1,4) AS purpose,
           v.LoanNum AS loan_num,
           v.Borr1LastName AS borrower_last_name,
           p._State AS state,
           mt.MortgageType AS mortgage_type,
           ud.ProductCode AS product_code,
           ud.ProductDescription AS product_desc,
           la._LastName AS underwriter_name,
           cl.UW_Submit_Date AS uw_submitted_at,
           DATEDIFF(d, cl.UW_Submit_Date, GETDATE()) AS age,
           CASE WHEN v.LoanAmount > 417000 THEN 'Yes' ELSE 'No' END AS is_jumbo_candidate,
          (SELECT cf2.AttributeValue
             FROM LENDER_LOAN_SERVICE.dbo.CUSTOM_FIELD cf2
            WHERE cf2.loanGeneral_Id = cf.loanGeneral_Id
              AND cf2.FormUniqueName = cf.FormUniqueName
              AND cf2.InstanceSequence = cf.InstanceSequence
              AND cf2.AttributeUniqueName = 'UWPACConditions') AS pac_condition,
          (SELECT cf2.AttributeValue
             FROM LENDER_LOAN_SERVICE.dbo.CUSTOM_FIELD cf2
            WHERE cf2.loanGeneral_Id = cf.loanGeneral_Id
              AND cf2.FormUniqueName = cf.FormUniqueName
              AND cf2.InstanceSequence = cf.InstanceSequence
              AND cf2.AttributeUniqueName = 'UWSubmissionMIType') AS is_mi_required
      FROM LENDER_LOAN_SERVICE.dbo.vwLoan v
           INNER JOIN LENDER_LOAN_SERVICE.dbo.LOAN_ASSIGNEE la
             ON la.loanGeneral_Id = v.loanGeneral_Id
            AND la._Role = 'Underwriter'
           INNER JOIN LENDER_LOAN_SERVICE.dbo.ctm_Loan as cl
             ON cl.Loan_Num = v.LoanNum
           INNER JOIN LENDER_LOAN_SERVICE.dbo.MORTGAGE_TERMS mt
             ON mt.loanGeneral_Id = v.loanGeneral_Id
           INNER JOIN LENDER_LOAN_SERVICE.dbo.UNDERWRITING_DATA ud
             ON ud.loanGeneral_Id = v.loanGeneral_Id
           INNER JOIN LENDER_LOAN_SERVICE.dbo.PROPERTY p
             ON p.loanGeneral_Id = v.loanGeneral_Id
           INNER JOIN LENDER_LOAN_SERVICE.dbo.CUSTOM_FIELD cf
             ON cf.loanGeneral_Id = v.loanGeneral_Id
            AND cf.FormUniqueName = 'Submit Conditions to UW'
            AND cf.AttributeUniqueName = 'UWConditions'
            AND cf.AttributeValue = 'Y'
            AND NOT EXISTS
               (SELECT 1 FROM LENDER_LOAN_SERVICE.dbo.CUSTOM_FIELD cf2
                 WHERE cf2.loanGeneral_Id = cf.loanGeneral_Id
                   AND cf2.FormUniqueName = cf.FormUniqueName
                   AND cf2.InstanceSequence = cf.InstanceSequence
                   AND cf2.AttributeUniqueName = 'UWConditionsRcvd')
           LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOAN_PURPOSE lp
             ON lp.loanGeneral_Id = v.loanGeneral_Id
    eos
  end
end
