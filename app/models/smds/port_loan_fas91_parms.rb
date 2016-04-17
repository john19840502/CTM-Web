class Smds::PortLoanFas91Parms < ::DatabaseDatamart
  self.table_name_prefix += 'smds_' unless self.table_name_prefix.include?('smds')

  def self.primary_key
    'ID'
  end

  CREATE_VIEW_SQL = <<-eos
    SELECT  ID                as id,
            Channel           as channel,
            DeferredWholesaleCommPct as deferred_wholesale_commission_percent,
            DeferredRetailCommAmt as deferred_retail_commission_amount,
            SalaryAndBenefitsAmt as salary_and_benefits_amount,
            LoanLevelCostsAmt as loan_level_costs_amount,
            BeginDt           as begin_on,
            EndDt             as end_on,
            EntryDt           as entered_on
    FROM CTM.smds.SMDSPortLoanFAS91Parms
  eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

end
