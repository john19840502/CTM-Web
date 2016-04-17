class LoanTransaction < DatabaseDatamartReadonly
   def self.sqlserver_create_view
    <<-eos
      SELECT
        DATAMART_LOAN_TRANSACTION_id        AS    loan_transaction_id,
        LenderRegistrationIdentifier        AS    lender_registration_identifier,
        FileGenerationTrigger               AS    file_generation_trigger,
        FileGenerationDateTime              AS    file_generation_at,
        UpdatedByUserIdentifier             AS    updated_by_user_id,
        UpdatedByUserLoginIdentifier        AS    updated_by_login_identifier,
        UpdatedByUserName                   AS    updated_by_username,
        LoanDataUpdatedDateTime             AS    loan_data_updated_at,
        BorrowerNameIn1003                  AS    borrower_name,
        BorrowerRequestedLoanAmountIn1003   AS    loan_amount
      FROM LENDER_LOAN_SERVICE.dbo.[DATAMART_LOAN_TRANSACTION]
    eos
  end
end
