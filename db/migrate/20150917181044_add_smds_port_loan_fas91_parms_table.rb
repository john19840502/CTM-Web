class AddSmdsPortLoanFas91ParmsTable < ActiveRecord::Migration
  def up
    return unless Rails.env.development?
    return if ActiveRecord::Base.connection.tables.include?('SMDSPortLoanFAS91Parms')
    execute <<-SQL
      CREATE TABLE smds.SMDSPortLoanFAS91Parms (
        ID integer primary key not null,
        Channel varchar(50) null,
        DeferredWholesaleCommPct decimal(10, 6) null,
        DeferredRetailCommAmt money null,
        SalaryAndBenefitsAmt money null,
        LoanLevelCostsAmt money null,
        BeginDt datetime null,
        EndDt datetime null,
        EntryDt datetime not null,
        UpdateDt datetime null )
    SQL
  end

  def down
    return unless Rails.env.development?
    execute <<-SQL
      DROP TABLE smds.SMDSPortLoanFAS91Parms
    SQL
  end
end
