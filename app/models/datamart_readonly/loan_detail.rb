class LoanDetail < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT    LOAN_DETAILS_id                AS id,
        loanGeneral_Id                     AS loan_general_id,
        CancelledPostponedDate             AS cancelled_date,
        CDBorrowerReceivedDisclosure       AS cd_borrower_received_disclosure,
        CDDisclosureDate                   AS cd_disclosure_date,
        CDDisclosureMethodType             AS cd_disclosure_method_type,
        CDRedisclosureDate                 AS cd_redisclosure_date,
        CDRedisclosureMethodType           AS cd_redisclosure_method_type,
        ClosingDate                        AS closing_date,
        DisbursementDate                   AS disbursement_date,
        DocumentPreparationDate            AS document_preparation_date,
        DocumentOutDate                    AS document_out_date,
        DocsDeliveryEmailAddress           AS document_email_address
      FROM       LENDER_LOAN_SERVICE.dbo.[LOAN_DETAILS]
  eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def disbursement_date
    super.try(:to_date)
  end

  def cancelled_date
    super.try(:to_date)
  end
end
