class LoanEvent < DatabaseDatamartReadonly
  belongs_to :loan_general
  belongs_to :closing_request_received, :foreign_key => 'loan_general_id', :primary_key => 'id'
  has_one :originator, through: :loan_general
  has_one :loan, through: :loan_general
  has_many :loan_officer_audits

  scope :closing_request_submitted_events, ->{ where(event_description: 'Closing Request Submitted') }

  delegate :loan_id, to: :loan_general

  def self.sqlserver_create_view
    <<-eos
      SELECT     LOAN_EVENT_id AS id,
             loanGeneral_Id AS loan_general_id,
             EventDate AS event_date,
             UpdatedByUserLoginIdentifier AS updated_by_user_login_identifier,
             UpdatedByUserFirstName AS updated_by_user_first_name,
             UpdatedByUserLastName AS updated_by_user_last_name,
             EventDescription AS event_description
      FROM       LENDER_LOAN_SERVICE.dbo.[LOAN_EVENT]
    eos
  end

  
  
  def create_or_update_loan_officer_audit
    if loan
      if loan.loan_officer_audits.empty?
        add_loan_officer_audit 'insert'
      else
        add_loan_officer_audit 'updating'
      #  loa = loan.loan_officer_audits.order(:event_date).last
      #  add_loan_officer_audit('updating') unless loa.datamart_user_id.eql?(datamart_user_id)
      end
    end
  end
  private :create_or_update_loan_officer_audit
  
  def  add_loan_officer_audit(event_type)
    audit_hash = {
        loan_id: loan_id,
        event_date: event_date,
        datamart_user_id: datamart_user_id
    }
    if 'updating' == event_type
      loan_officer_audits.create(audit_hash) unless loan_officer_audits.any?
    else
      loan_officer_audits.create(audit_hash)
    end
  end
  private :add_loan_officer_audit

  def datamart_user_id
    originator && originator.id
  end

  #def loan_id
  #  loan && loan.id
  #end
end
