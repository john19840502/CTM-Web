class ChangeDataTypeOfAgentAmentDocumentsInTridSettlement < ActiveRecord::Migration
  def change
    change_column :settlement_agent_trid_audits, :agent_amend_documents_for_trust_occurance, :integer
  end
end
