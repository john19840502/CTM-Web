class UpdateSmdsJumboFixedLoanTable < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        DROP TABLE smds.SMDSJumboFixedLoans
      SQL
      
      execute <<-SQL
        CREATE TABLE [smds].[SMDSJumboFixedLoans](
          [LnNbr] [varchar](50) NOT NULL,
          [ProductCode] [varchar](50) NULL,
          [ConfirmCode] [varchar](50) NULL,
          [LockDate] [datetime] NULL,
          [LockPeriod] [int] NULL,
          [LockExpires] [datetime] NULL,
          [InitialLock] [datetime] NULL,
          [TotalLnAmt] [money] NULL,
          [Borrower] [varchar](100) NULL,
          [EntryDt] [datetime] NOT NULL,
          [UpdateDt] [datetime] NOT NULL,
          [NoteRate] [decimal](8, 4) NULL,
          [LTV] [decimal](8, 4) NULL,
          [FICO] [smallint] NULL,
          [InvestorName] [varchar](50) NULL,
          [PricingDate] [date] NULL,
          [SecondaryPricingID] [bigint] NULL
        )
      SQL
    end
  end

  def down
  end
end
