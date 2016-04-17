class ChangeIvestorPricingImportName < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        DROP TABLE [ctm].[PricingImport]
      SQL
    end
    
    if Rails.env.development?
      execute <<-SQL
        CREATE TABLE [ctm].[secondary_pricing_imports](
          [id] [bigint] IDENTITY(1,1) NOT NULL,
          [pricing_date] [datetime] NULL,
          [pricing_id] [varchar](255) NULL,
          [note_rate] [decimal](8, 4) NULL,
          [lock_days] [smallint] NULL,
          [price] [decimal](15, 12) NULL,
          [lock_days2] [smallint] NULL,
          [price2] [decimal](15, 12) NULL,
          [lock_days3] [smallint] NULL,
          [price3] [decimal](15, 12) NULL,
          [lock_days4] [smallint] NULL,
          [price4] [decimal](15, 12) NULL,
          [product_code] [varchar](50) NULL,
          [product_id] [smallint] NULL,
          [investor_name] [varchar](50) NULL,
          [investor_id] [smallint] NULL
        )
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        DROP TABLE [ctm].[secondary_pricing_imports]
      SQL
    end

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
end
