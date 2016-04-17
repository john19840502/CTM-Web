class AddAuditedBySuspenseToSettlementAgentAudits < ActiveRecord::Migration
  def change
    add_column :settlement_agent_audits, :audited_by_suspense, :string
  end
end
