class LoanNote < DatabaseDatamart
  FUNDING_REQUEST_CONDITIONS = { note_type: "FDREQ" }
  CLOSING_REQUEST_CONDITIONS = { note_type: 'CLREQ' }

  attr_accessible :note_type, :create_user, :text, :ctm_user_id, :loan_id

  belongs_to :ctm_loan, foreign_key: :loan_id, primary_key: :loan_id
  belongs_to :scheduled_funding, foreign_key: :loan_id, primary_key: :id
  belongs_to :closing_requests_awaiting_review, foreign_key: 'loan_id', primary_key: 'id'
  belongs_to :ctm_user

  validates :ctm_loan, presence: true
  validates :create_user, presence: true
  validates_each :text, :note_type  do |record, attr, value|
    record.errors.add(attr, 'must not be nil') if value.nil?
  end

  delegate :domain_login, to: :ctm_user, prefix: true, allow_nil: true

  CREATE_VIEW_SQL =  <<-eos
      SELECT     ln.ID AS id,
                 ln.Loan_Num AS loan_id,
                 ln.Note_Text AS text,
                 ln.Note_Type AS note_type,
                 ln.Update_User AS ctm_user_id,
                 ln.Create_Date AS created_at,
                 ln.Create_User AS create_user,
                 ln.Update_Date AS updated_at
      FROM       [CTM].[ctm].[LOAN_NOTE] AS ln
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

  def to_label
    "#{text}"
  end
  alias :to_s :to_label

  def last_updated_by
    ctm_user_domain_login
  end
end
