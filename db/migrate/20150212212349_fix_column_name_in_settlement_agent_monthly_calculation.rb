class FixColumnNameInSettlementAgentMonthlyCalculation < ActiveRecord::Migration
  def up
    rename_column :settlement_agent_monthly_calculations, :settlement_agent_id, :settlement_agent
  end

  def down
    rename_column :settlement_agent_monthly_calculations, :settlement_agent, :settlement_agent_id
  end
end
