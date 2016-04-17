class AddQcountToSettlementAgentAudit < ActiveRecord::Migration
  def up
    add_column :settlement_agent_audits, :qcount, :integer, default: 35
    SettlementAgentAudit.update_all(qcount: 19)
  end

  def down
    remove_column :settlement_agent_audits, :qcount
  end
end
