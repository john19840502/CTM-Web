class AddAppraisalSentAndSecondAppraisalToUnderwriterDatum < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE LENDER_LOAN_SERVICE.dbo.UNDERWRITING_DATA
          ADD AppraisalSentToBorrower datetime,
              SecondAppraisalSentToBorrower datetime
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE LENDER_LOAN_SERVICE.dbo.UNDERWRITING_DATA
          DROP COLUMN AppraisalSentToBorrower,
                      SecondAppraisalSentToBorrower
      SQL
    end
  end
end
