class MailingAddress < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT   BorrowerID AS id,
               loanGeneral_Id AS loan_general_id,
               _StreetAddress AS address,
               _City AS city,
               _State AS state,
               _PostalCode AS zip,
               _Country AS country
      FROM       LENDER_LOAN_SERVICE.dbo.[_MAIL_TO]
    eos



  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def self.primary
    order(:id).uniq(&:id).first
  end

  def self.brw1
    where(id: "BRW1")
  end

  def mailing_address
    [ address, city, state, zip ].compact.join(", ")
  end
end
