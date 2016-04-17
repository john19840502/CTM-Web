module Mdb
  class DataChangeReport
    include Mongoid::Document

    field :loan_num, type: String

    embeds_many :loan_compliance_event_changes, class_name: 'Mdb::LoanComplianceEventChange'

#    attr_accessible :loan_num, :loan_compliance_event_changes
    accepts_nested_attributes_for :loan_compliance_event_changes, allow_destroy: true, reject_if: :all_blank

    def self.record_change loan_num, audit_hash, user
      la = LoanComplianceEventAudit.find_or_initialize_by(loan_num: loan_num)

      username = user ? "#{user.first_name} #{user.last_name}" : 0
      user_id = user.uuid if user

      lec = Mdb::LoanComplianceEventChange.new
      lec.changed_values = audit_hash
      lec.username = username
      lec.user_id = user_id
      lec.changed_at = DateTime.now
      
      la.loan_compliance_event_changes << lec
      la.save!
    end
  end
end
