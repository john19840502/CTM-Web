class AddPageCountsToSettlementAgentAudit < ActiveRecord::Migration
  def up
    add_column :settlement_agent_audits, :agent_page1_count, :integer, default: 0
    add_column :settlement_agent_audits, :agent_page2_count, :integer, default: 0
    add_column :settlement_agent_audits, :agent_page3_count, :integer, default: 0

    SettlementAgentAudit.reset_column_information
    change_column_null(:settlement_agent_audits, :agent_page1_count, false, 0)
    change_column_null(:settlement_agent_audits, :agent_page2_count, false, 0)
    change_column_null(:settlement_agent_audits, :agent_page3_count, false, 0)
  end

  def down
    remove_column :settlement_agent_audits, :agent_page1_count
    remove_column :settlement_agent_audits, :agent_page2_count
    remove_column :settlement_agent_audits, :agent_page3_count
  end
end
