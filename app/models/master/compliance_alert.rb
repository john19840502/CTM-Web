require 'ctm/ms_sql_view'
module Master
  class ComplianceAlert < Avista::ReadOnly
    extend ::CTM::MSSqlView

    belongs_to :loan, class_name: 'Master::Loan', inverse_of: :compliance_alerts

    from 'COMPLIANCE_ALERTS', as: 'alert'

    field :id,               column: 'COMPLIANCE_ALERTS_Id'
    field :loan_id,          column: 'loanGeneral_Id'
    field :hpml_alert_test,  column: 'HPMLAlertTest'
    field :application_date, column: 'ApplicationDate'

    def self.sqlserver_create_view
      self.build_query
    end

    def hpml?
      hpml_alert_test == 'Fail'
    end
  end
end