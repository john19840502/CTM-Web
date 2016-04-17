class ClosingAgent < DatabaseDatamartReadonly
  belongs_to :loan_general
  has_many :settlement_agent_audits
  
  def self.sqlserver_create_view
    <<-eos
      SELECT     CLOSING_AGENT_id               AS id,
             loanGeneral_Id                     AS loan_general_id,
             _Type                              AS agent_type,
             _UnparsedName                      AS name
      FROM       LENDER_LOAN_SERVICE.dbo.[CLOSING_AGENT]
    eos
  end
end