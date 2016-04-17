class CreateInvestorPricingImport < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        CREATE TABLE [ctm].[PricingImport]
          (
          [ID] [int] IDENTITY(1,1) NOT NULL,
          [CreatedDate] [datetime] NOT NULL,
          [PricingID] [varchar](255) NULL,
          [NoteRate] [decimal](8, 4) NULL,
          [LockDays] [smallint] NULL,
          [Price] [decimal](15, 12) NULL,
          [LockDays2] [smallint] NULL,
          [Price2] [decimal](15, 12) NULL,
          [LockDays3] [smallint] NULL,
          [Price3] [decimal](15, 12) NULL,
          [LockDays4] [smallint] NULL,
          [Price4] [decimal](15, 12) NULL,
          [ProductCode] [varchar](50) NULL,
          [ProductID] [smallint] NULL,
          [InvestorName] [varchar](50) NULL,
          [InvestorID] [smallint] NULL
          )
      SQL
    end

  end

  def down
    if Rails.env.development?
      execute <<-SQL
        DROP TABLE [ctm].[PricingImport]
      SQL
    end
  end
end
