class CreateCtmDisclosureRequestTimestampsTableDevOnly < ActiveRecord::Migration
  def up
    return unless Rails.env.development?
    execute <<-SQL
      CREATE TABLE [ctm].[disclosure_request_timestamps](
        [id] [int] IDENTITY(1,1) NOT NULL,
        [loan_number] [varchar](50) NOT NULL,
        [disclosure_request_date] [datetime] NULL,
        [created_at] [datetime] NOT NULL,
        [updated_at] [datetime] NOT NULL
      )
    SQL
  end

  def down
    return unless Rails.env.development?
    execute <<-SQL
      DROP TABLE [ctm].[disclosure_request_timestamps]
    SQL
  end
end
