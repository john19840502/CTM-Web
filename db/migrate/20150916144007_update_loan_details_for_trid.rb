class UpdateLoanDetailsForTrid < ActiveRecord::Migration
  def up
    # TRID change.  It should not run in prod env
    if Rails.env.development?
      execute <<-SQL
          ALTER TABLE LENDER_LOAN_SERVICE.dbo.LOAN_DETAILS
            ADD CDDisclosureMethodType varchar(50),
                CDBorrowerReceivedDisclosure datetime,
                CDRedisclosureDate datetime
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
          ALTER TABLE LENDER_LOAN_SERVICE.dbo.LOAN_DETAILS
            DROP COLUMN CDDisclosureMethodType,
                        CDBorrowerReceivedDisclosure,
                        CDRedisclosureDate
      SQL
    end
  end
end
