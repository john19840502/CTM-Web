class HpmlResult
  def self.for(loan)
    loan.compliance_alerts.any?(&:hpml?)
  end
end
