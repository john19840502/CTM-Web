class Employment < DatabaseDatamartReadonly
  belongs_to :borrower

  scope :current, ->{ where(:is_current => true) }

  CREATE_VIEW_SQL = <<-eos
      SELECT     e.EMPLOYER_id AS id, lg.LenderRegistrationIdentifier AS loan_id, lg.LenderRegistrationIdentifier + RIGHT('0000' + REPLACE(e.BorrowerID, 'BRW', ''), 3)
                            AS borrower_id, e._Name AS name, e.EmploymentBorrowerSelfEmployedIndicator AS is_self_employed, e.EmploymentCurrentIndicator AS is_current,
                            e.IncomeEmploymentMonthlyAmount AS monthly_income
      FROM         LENDER_LOAN_SERVICE.dbo.LOAN_GENERAL AS lg INNER JOIN
                            LENDER_LOAN_SERVICE.dbo.EMPLOYER AS e ON lg.loanGeneral_Id = e.loanGeneral_Id
    eos
  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

end
