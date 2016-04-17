class AddSecondAppraisalDelMothodToUnderwritingDatum < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE LENDER_LOAN_SERVICE.dbo.UNDERWRITING_DATA
          ADD SecondAppraisalDeliveryMethod INT
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE LENDER_LOAN_SERVICE.dbo.UNDERWRITING_DATA
          DROP COLUMN SecondAppraisalDeliveryMethod
      SQL
    end
  end
end
