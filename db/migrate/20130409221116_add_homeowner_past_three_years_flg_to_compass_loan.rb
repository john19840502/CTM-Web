class AddHomeownerPastThreeYearsFlgToCompassLoan < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          ADD HomeownerPastThreeYearsFlg      varchar(1)
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP COLUMN HomeownerPastThreeYearsFlg
      SQL
    end
  end
end
