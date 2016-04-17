class AddPercentageToProduct < ActiveRecord::Migration
  def up
    # TRID change.  It should not run in prod env
    if Rails.env.development?
      execute <<-SQL
          ALTER TABLE LENDER_LOAN_SERVICE.dbo.PRODUCT
            ADD Percentage DECIMAL(14,3) DEFAULT NULL
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
          ALTER TABLE LENDER_LOAN_SERVICE.dbo.PRODUCT
            DROP COLUMN Percentage
      SQL
    end
  end
end
