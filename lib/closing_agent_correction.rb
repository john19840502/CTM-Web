class ClosingAgentCorrection
  def self.update_data
    loans = SettlementAgentAudit.pluck(:loan_id).uniq
    loans.each do |loan|
      audit = SettlementAgentAudit.where(loan_id: loan).last
      agent = Loan.find(loan).loan_general.closing_agents.where{ agent_type == "TitleCompany"}.first.name rescue nil
      audit.update_attributes({settlement_agent_id: agent}, without_protection: true)
    end
  end
end
