class AddApplicationDateToComplianceAlerts < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE LENDER_LOAN_SERVICE.dbo.COMPLIANCE_ALERTS
          ADD ApplicationDate datetime
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE LENDER_LOAN_SERVICE.dbo.COMPLIANCE_ALERTS
          DROP COLUMN ApplicationDate 
      SQL
    end
  end
end
