class AddTimestampsSettlementAgentTridAudit < ActiveRecord::Migration
  def change
    add_column :settlement_agent_trid_audits, :audited_by_suspense, :string
    add_column :settlement_agent_trid_audits, :created_at, :datetime
    add_column :settlement_agent_trid_audits, :updated_at, :datetime
  end
end
