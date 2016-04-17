require 'filter_by_date_model_methods'

class ScheduledFunding < DatabaseDatamartReadonly
  coerce_sqlserver_date :disbursed_at

  alias_attribute :scheduled_funding_id, :id

  belongs_to :loan_general

  has_one :funding_request_note, ->{ where(LoanNote::FUNDING_REQUEST_CONDITIONS)},
    class_name: 'LoanNote', foreign_key: :loan_id, primary_key: :id
  has_one  :interviewer, foreign_key: 'loan_id'
  has_one  :property, foreign_key: 'loan_general_id', primary_key: 'loan_general_id'
  has_one :ctm_user, through: :funding_request_note
  has_one :branch, through: :loan_general, source: :institution

  delegate :text, :to => :funding_request_note, :prefix => "note", :allow_nil => true
  delegate :domain_login, to: :ctm_user, prefix: true, allow_nil: true
  delegate :state, to: :property, prefix: true, allow_nil: true
  delegate :name, to: :branch, prefix: true, allow_nil: true

  extend FilterByDateModelMethods

  def self.filter_by_date_method
    :disbursed_at
  end

  def self.filter_by_date_includes
    includes(:funding_request_note, :ctm_user, :property)
  end

  def self.channel_options
    Channel.all.map(&:identifier)
  end

  CREATE_VIEW_SQL = <<-eos
      SELECT v.LoanNum                                          AS id,
             v.loanGeneral_Id                                   AS loan_general_id,
             v.Borr1LastName                                    AS borrower_last_name,
             v.Channel                                          AS channel,
             lp.[_Type]                                         AS loan_purpose,
             v.[InstitutionIdentifier] + ' - ' + v.[BranchName] AS branch_listing,
             mt.BorrowerRequestedLoanAmount                     AS borrower_requested_loan_amount,
             ld.DisbursementDate                                AS disbursed_at

      FROM       LENDER_LOAN_SERVICE.dbo.vwLoan       AS v
      INNER JOIN LENDER_LOAN_SERVICE.dbo.FUNDING_DATA AS fd
        ON  fd.loanGeneral_Id = v.loanGeneral_Id
        AND fd.[_RequestReceivedDate] IS NOT NULL
      INNER JOIN LENDER_LOAN_SERVICE.dbo.LOAN_PURPOSE lp
        ON lp.loanGeneral_Id = v.loanGeneral_Id
      INNER JOIN LENDER_LOAN_SERVICE.dbo.LOAN_DETAILS AS ld
        ON ld.loanGeneral_Id = v.loanGeneral_Id
        AND ld.CancelledPostponedDate IS NULL
      INNER JOIN LENDER_LOAN_SERVICE.dbo.MORTGAGE_TERMS AS mt
        ON mt.loanGeneral_Id = v.loanGeneral_Id
    eos

  alias_attribute :loan_id, :id

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def branch_id
    # change to institution number as per CTMWEB-191
    self.branch.try(:institution_number)
  end

  def branch_listing
    "#{branch_id} - #{branch_name}"
  end

  def note_last_updated_by
    ctm_user_domain_login
  end
end
