class AddTablesForSecondaryPricingForCreditSuisse < ActiveRecord::Migration
  def up
    if Rails.env.development?
      execute <<-SQL
        CREATE TABLE [ctm].[secondary_pricing_sheets](
          [id] [int] IDENTITY(1,1) NOT NULL,
          [pricing_date] [date] NOT NULL,
          [created_at] [datetime] NOT NULL
        )
      SQL
      execute <<-SQL
        CREATE TABLE [ctm].[secondary_pricing](
          [id] [bigint] IDENTITY(1,1) NOT NULL,
          [pricing_sheet_id] [int] NOT NULL,
          [product_id] [smallint] NOT NULL,
          [investor_id] [smallint] NOT NULL,
          [note_rate] [decimal](8, 4) NOT NULL,
          [lock_days] [smallint] NOT NULL,
          [price] [decimal](15, 12) NOT NULL
        )
      SQL
      execute <<-SQL
        CREATE TABLE [ctm].[secondary_investors](
          [id] [smallint] IDENTITY(1,1) NOT NULL,
          [investor_name] [varchar](50) NOT NULL,
          [is_active] [bit] NOT NULL,
          [is_jumbo] [bit] NOT NULL,
          [created_at] [datetime] NOT NULL,
          [updated_at] [datetime] NOT NULL
        )
      SQL
      execute <<-SQL
        CREATE TABLE [ctm].[secondary_products](
          [id] [smallint] IDENTITY(1,1) NOT NULL,
          [product_code] [varchar](50) NOT NULL,
          [is_active] [bit] NOT NULL,
          [is_jumbo] [bit] NOT NULL,
          [created_at] [datetime] NOT NULL,
          [updated_at] [datetime] NOT NULL
        )
      SQL
      execute <<-SQL
        ALTER TABLE smds.SMDSJumboFixedLoans
          ADD [SecondaryPricingID] [bigint] NULL
      SQL
    end
  end

  def down
    if Rails.env.development?
      execute <<-SQL
        DROP TABLE [ctm].[secondary_pricing_sheets]
      SQL
    
      execute <<-SQL
        DROP TABLE [ctm].[secondary_pricing]
      SQL

      execute <<-SQL
        DROP TABLE [ctm].[secondary_investors]
      SQL
  
      execute <<-SQL
        DROP TABLE [ctm].[secondary_products]
      SQL

      execute <<-SQL
        ALTER TABLE smds.SMDSJumboFixedLoans
          DROP COLUMN [SecondaryPricingID] [bigint] NULL
      SQL
    end
  end
end
