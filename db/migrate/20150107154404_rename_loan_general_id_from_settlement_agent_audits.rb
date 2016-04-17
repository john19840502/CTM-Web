class RenameLoanGeneralIdFromSettlementAgentAudits < ActiveRecord::Migration
  def up
  	rename_column :settlement_agent_audits, :loan_general_id, :loan_id
  	change_column :settlement_agent_audits, :loan_id, :string
  end

  def down
  	rename_column :settlement_agent_audits, :loan_id, :loan_general_id
  	change_column :settlement_agent_audits, :loan_general_id, :integer
  end
end
