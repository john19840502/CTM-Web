class AddConsentToWaiveDeliveryMethodToUnderwritingData < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE LENDER_LOAN_SERVICE.dbo.UNDERWRITING_DATA
          ADD ConsentToWaiveDeliveryReceived DATETIME
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE LENDER_LOAN_SERVICE.dbo.UNDERWRITING_DATA
          DROP COLUMN ConsentToWaiveDeliveryReceived
      SQL
    end
  end
end
