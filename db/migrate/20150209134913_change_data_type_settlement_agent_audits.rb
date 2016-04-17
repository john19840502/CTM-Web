class ChangeDataTypeSettlementAgentAudits < ActiveRecord::Migration
  def up
    change_column :settlement_agent_audits, :settlement_agent_id, :string
  end

  def down
    change_column :settlement_agent_audits, :settlement_agent_id, :integer
  end
end
