class AddIntexToSettlementAgentMonthlyCalculation < ActiveRecord::Migration
  def up
    add_index :settlement_agent_monthly_calculations, :month 
    add_index :settlement_agent_monthly_calculations, :settlement_agent
    add_index :settlement_agent_monthly_calculations, :escrow_agent_id
  end
  def down
    remove_index  :settlement_agent_monthly_calculations, :month 
    remove_index  :settlement_agent_monthly_calculations, :settlement_agent 
    remove_index  :settlement_agent_monthly_calculations, :escrow_agent_id
  end
end
