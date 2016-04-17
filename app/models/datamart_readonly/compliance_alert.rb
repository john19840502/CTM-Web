class ComplianceAlert < DatabaseDatamartReadonly
  belongs_to :loan_general

  CREATE_VIEW_SQL = <<-eos
      SELECT     COMPLIANCE_ALERTS_Id AS id,
                 loanGeneral_Id AS loan_general_id,
                 ApplicationDate AS application_date
      FROM       LENDER_LOAN_SERVICE.dbo.[COMPLIANCE_ALERTS]
    eos

  def self.sqlserver_create_view
    CREATE_VIEW_SQL
  end

end