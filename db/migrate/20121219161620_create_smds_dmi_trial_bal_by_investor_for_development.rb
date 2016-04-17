class CreateSmdsDmiTrialBalByInvestorForDevelopment < ActiveRecord::Migration
  def up
    if Rails.env.development? && !ActiveRecord::Base.connection.tables.include?('SMDSDMITrialBalByInvestor')
      execute <<-SQL
        CREATE TABLE smds.SMDSDMITrialBalByInvestor (
          InvestorCode VARCHAR(5),
          DMILnNbr VARCHAR(25),
          MthlyPmtAmt MONEY,
          InvestorLnNbr VARCHAR(25),
          TypeCode VARCHAR(5),
          PFPCode VARCHAR(5),
          BorrLName VARCHAR(50),
          DueDate VARCHAR(10),
          PrincipalBal MONEY,
          EscrowBal MONEY,
          LateChargeAmt MONEY,
          PIConstant MONEY,
          NoteRate DECIMAL(8, 4),
          PdOff VARCHAR(1),
          InCurrFile VARCHAR(1),
          created_at DATETIME,
          updated_at DATETIME )
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        DROP TABLE smds.SMDSDMITrialBalByInvestor
      SQL
    end
  end
end
