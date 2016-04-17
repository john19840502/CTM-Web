class WireTracking < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT   WIRE_TRACKING_id AS id,
               loanGeneral_Id AS loan_general_id,
               WireSentDate AS sent_date,
               Comments AS comments,
               Amount AS amt,
               WireNumber AS wire_num,
               CheckNumber AS check_num,
               FundingNumber AS funding_num,
               CheckVoidedDate AS voided_date
      FROM       LENDER_LOAN_SERVICE.dbo.[WIRE_TRACKING]
    eos



  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end
end
