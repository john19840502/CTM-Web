class ChangeSmdsDmiTrialBalByInvestorName < ActiveRecord::Migration
  def up
    tables = ActiveRecord::Base.connection.tables
    if Rails.env.development? && tables.include?('SMDSDMITrialBalByInvestor')
      execute <<-SQL
        sp_RENAME 'CTM.smds.SMDSDMITrialBalByInvestor', 'DMITrialBalByInvestor'
      SQL
    end
  end

  def down
    if Rails.env.development? && !tables.include?('SMDSDMITrialBalByInvestor')
      execute <<-SQL
        sp_RENAME 'CTM.smds.DMITrialBalByInvestor', 'SMDSDMITrialBalByInvestor'
      SQL
    end
  end
end
