class FixColumnNameInSettlementAgentAudit < ActiveRecord::Migration
  def up
    rename_column :settlement_agent_audits, :settlement_agent_id, :settlement_agent
  end

  def down
    rename_column :settlement_agent_audits, :settlement_agent, :settlement_agent_id
  end
end
