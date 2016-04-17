class LoanOfficerAudit < DatabaseRailway
  belongs_to :loan
  
  def self.create_or_update_loan_officer_audit(loan)
    if loan.present? && loan.loan_general.present?
      begin
        originator_id = loan.loan_general.originator.id
      rescue Exception => e
        return
      end
      audits = LoanOfficerAudit.where(:loan_id => loan.id)
      if audits.empty?
        self.create({
          loan_event_id: loan.id,
          loan_id: loan.id,
          event_date: DateTime.now.utc,
          datamart_user_id: originator_id}, without_protection: true)
      else
        last_audit = audits.order(:event_date).last
        if last_audit.datamart_user_id != originator_id
          self.create({
            loan_event_id: loan.id,
            loan_id: loan.id,
            event_date: DateTime.now.utc,
            datamart_user_id: originator_id}, without_protection: true)
        end
      end
    end
  end
end
