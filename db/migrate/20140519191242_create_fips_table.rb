class CreateFipsTable < ActiveRecord::Migration
  def change

    return unless Rails.env.development?

    p 'creating table'

    execute %Q{ 
      IF (EXISTS (SELECT * 
                       FROM INFORMATION_SCHEMA.TABLES 
                       WHERE TABLE_SCHEMA = 'ctm' 
                       AND  TABLE_NAME = 'FIPSCodesByCityStateZip'))
      BEGIN
        DROP TABLE  [ctm].[FIPSCodesByCityStateZip]
      END

      CREATE TABLE [ctm].[FIPSCodesByCityStateZip](
        [CityName] [varchar](28) NOT NULL,
        [StateCode] [varchar](2) NOT NULL,
        [ZIPCode] [varchar](5) NOT NULL,
        [AreaCode] [varchar](3) NULL,
        [CountyFIPS] [varchar](5) NOT NULL,
        [CountyName] [varchar](25) NULL,
        [Preferred?] [varchar](1) NULL,
        [ZIPCodeType] [varchar](1) NULL,
       CONSTRAINT [PK_FIPSCodesByCityStateZip] PRIMARY KEY NONCLUSTERED 
      (
        [CityName] ASC,
        [StateCode] ASC,
        [ZIPCode] ASC
      )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
      ) ON [PRIMARY]

    }

    p 'created table'

  end
end
