class UpdateSmdsLoanDetails < ActiveRecord::Migration
  def up
    if Rails.env.development? && !ActiveRecord::Base.connection.column_exists?('smds.SMDSLoanDetails', 'RelocationLoanFlag')
      execute <<-SQL
        ALTER TABLE smds.SMDSLoanDetails
          ADD
              RelocationLoanFlag      VARCHAR(1)
      SQL
    end
    if Rails.env.development? && !ActiveRecord::Base.connection.column_exists?('smds.SMDSRedwoodLoansImported', 'LockTerm')
      execute <<-SQL
        ALTER TABLE smds.SMDSRedwoodLoansImported
          ADD
              LockTerm                SMALLINT
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        ALTER TABLE smds.SMDSLoanDetails
          DROP COLUMN
                      RelocationLoanFlag
      SQL
      execute <<-SQL
        ALTER TABLE smds.SMDSRedwoodLoansImported
          DROP COLUMN
              LockTerm

      SQL
    end
  end
end
