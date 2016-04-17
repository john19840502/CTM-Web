class CreateFeeReductionZipCodesTableDevOnly < ActiveRecord::Migration
  def up
    return unless Rails.env.development?
    execute <<-SQL
      CREATE TABLE [ctm].[fee_reduction_zip_codes](
        [id] [int] IDENTITY(1,1) NOT NULL,
        [zip_code] [varchar](50) NOT NULL,
        [county] [varchar](100) NULL,
        [state] [char](2) NULL,
        [created_at] [datetime] NOT NULL,
        [updated_at] [datetime] NOT NULL
      )
    SQL

    [ 60153, 60165, 60406, 60409, 60411, 60426, 60428, 60472, 60608,
      60609, 60612, 60615, 60617, 60619, 60620, 60621, 60623, 60624,
      60626, 60628, 60629, 60632, 60636, 60637, 60639, 60644, 60649,
      60651, 60653, 60827, 
    ].each do |zip|
      insert_zip_code(zip, "Cook County", "IL")
    end
 
    [ 30291, 30303, 30310, 30311, 30312, 30313, 30314, 30315, 30316,
      30318, 30331, 30336, 30337, 30344, 30349, 30354,
    ].each do |zip|
      insert_zip_code(zip, "Fulton County", "GA")
    end
  end

  def insert_zip_code(zip, county, state)
    return unless Rails.env.development?
    t = "'#{Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")}'"
    execute <<-SQL
      insert into [ctm].[fee_reduction_zip_codes](zip_code, county, state, created_at, updated_at)
      values('#{zip}', '#{county}', '#{state}', #{t}, #{t})
    SQL
  end

  def down
    return unless Rails.env.development?
    execute <<-SQL
      DROP TABLE [ctm].[fee_reduction_zip_codes]
    SQL
  end
end
