class LoanAssignee < DatabaseDatamartReadonly
  belongs_to :loan_general
  belongs_to :closing_request_received, :foreign_key => 'loan_general_id', :primary_key => 'id'

  def self.sqlserver_create_view
    <<-eos
      SELECT     LOAN_ASSIGNEE_id AS id,
                 loanGeneral_Id AS loan_general_id,
             _FirstName AS first_name,
             _LastName AS last_name,
             _Role AS role,
             AssignedDate AS assigned_at,
             ActionUserId AS action_user_id,
             ActionUserName AS action_user_name,
             _AssignedUserId AS assigned_user_id
      FROM       LENDER_LOAN_SERVICE.dbo.[LOAN_ASSIGNEE]
    eos
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end

  class Role

    ADMINISTRATOR = 'Administrator'
    AVISTA_TEST_ROLE = 'Avista Test Role'
    CLOSER = 'Closer'
    CLOSER_FUNDER = 'Closer/Funder'
    LENDER_MANAGER = 'Lender Manager'
    LENDER_PROCESSOR = 'Lender Processor'
    POST_CLOSER = 'Post Closer'
    SECONDARY = 'Secondary'
    UNDERWRITER = 'Underwriter'
    UNDERWRITER_MANAGER = 'Underwriting Manager'

  end

  scope :underwriter, ->{ where(role: Role::UNDERWRITER) }
  scope :closing_coordinator, ->{where(role: 'Closing Coordinator')}
  scope :jr_underwriter, ->{where(role: 'Jr. Underwriter')}
  scope :closer, ->{where(role: 'Closer/Funder')}
  scope :originator_processor, ->{where(role: 'Originator Processor')}

end

