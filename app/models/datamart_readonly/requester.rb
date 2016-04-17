class Requester < DatabaseDatamartReadonly
  belongs_to :loan_general

  def self.sqlserver_create_view
    <<-eos
      SELECT
        REQUESTER_id    AS id,
        loanGeneral_Id  AS loan_general_id,
        requestType     AS request_type,
        _Date           AS requested_date,
        _EmailAddress   AS email_address
        
      FROM         LENDER_LOAN_SERVICE.dbo.REQUESTER
    eos
  end
  #_UnparsedName   AS email_address ---> is this right?
end
