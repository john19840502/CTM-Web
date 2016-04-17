class AddFeatureCodesToSmdsCompassLoanDetails < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          ADD StringSFC VARCHAR(30),
              CntSFC SMALLINT
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSCompassLoanDetails
          DROP COLUMN StringSFC,
                      CntSFC
      SQL
    end
  end
end
