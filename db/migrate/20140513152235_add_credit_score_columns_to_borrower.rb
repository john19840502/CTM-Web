class AddCreditScoreColumnsToBorrower < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE LENDER_LOAN_SERVICE.dbo.BORROWER
          ADD EquifaxCreditScore INT,
              ExperianCreditScore INT,
              TransUnionCreditScore INT
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE LENDER_LOAN_SERVICE.dbo.BORROWER
          DROP COLUMN EquifaxCreditScore,
              ExperianCreditScore,
              TransUnionCreditScore
      SQL
    end
  end
end
