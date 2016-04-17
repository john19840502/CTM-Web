class BorrowerAddress < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT   BorrowerID AS id,
               loanGeneral_Id AS loan_general_id,
               HomeTelephoneNumber AS home_tele_num,
               EmailAddress AS email,
               Borrower_FirstLastName AS borrower_first_last_name,
               Borrower_FirstName AS borrower_first_name,
               Borrower_LastName AS borrower_last_name,
               Borrower_SSN AS ssn,
               Mail_Street_Address AS current_street_address,
               Mail_CityStateZip AS current_city_state_zip
      FROM       LENDER_LOAN_SERVICE.dbo.[vwBorrowerAddresses]
    eos



  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def self.primary
    order(:id).uniq(&:id).first
  end

  def mailing_address
    [ current_street_address, current_city_state_zip ].compact.join(", ")
  end


end
