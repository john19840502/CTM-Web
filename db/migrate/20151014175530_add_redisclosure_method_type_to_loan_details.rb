class AddRedisclosureMethodTypeToLoanDetails < ActiveRecord::Migration
  def up
    # TRID change.  It should not run in prod env
    if Rails.env.development?
      execute <<-SQL
          ALTER TABLE LENDER_LOAN_SERVICE.dbo.LOAN_DETAILS
            ADD CDRedisclosureMethodType varchar(50)
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
          ALTER TABLE LENDER_LOAN_SERVICE.dbo.LOAN_DETAILS
            DROP COLUMN CDRedisclosureMethodType
      SQL
    end
  end
end
