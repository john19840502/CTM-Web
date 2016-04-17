class AddIndexToSettlementAgentAudit < ActiveRecord::Migration
  def up
    add_index :settlement_agent_audits, :loan_id 
    add_index :settlement_agent_audits, :settlement_agent
    add_index :settlement_agent_audits, :escrow_agent_id
  end
  def down
    remove_index  :settlement_agent_audits, :loan_id 
    remove_index  :settlement_agent_audits, :settlement_agent 
    remove_index  :settlement_agent_audits, :escrow_agent_id
  end
end
