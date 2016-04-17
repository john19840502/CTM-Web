class Smds::PortfolioTrackingFlag < ::DatabaseDatamart
  self.table_name_prefix += 'smds_' unless self.table_name_prefix.include?('smds')

  def self.primary_key
    'ID'
  end

  CREATE_VIEW_SQL = <<-eos
    SELECT  ID                as id,
            Channel           as channel,
            ProductCode       as product_code,
            BegPortfolioDt    as beg_portfolio_on,
            EndPortfolioDt    as end_portfolio_on,
            EntryDt           as entered_on
    FROM CTM.smds.SMDSPortfolioTrackingFlag
  eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

end
